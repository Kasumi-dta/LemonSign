//
//  InstallPreview.swift
//  Feather
//
//  Created by samara on 22.04.2025.
//

import SwiftUI
import NimbleViews
import IDeviceSwift
import OSLog

// MARK: - View
struct InstallPreviewView: View {
	@Environment(\.dismiss) var dismiss
	
	// Sharing
	@AppStorage("Feather.useShareSheetForArchiving") private var _useShareSheet: Bool = false
	
	// Methods
    @AppStorage("Feather.installationMethod") private var _installationMethod: Int = 0
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	@State private var _isWebviewPresenting = false
    @State private var progressTask: Task<Void, Never>?
	@State private var payloadTimeoutTask: Task<Void, Never>?
	
	struct ServerAlertInfo: Identifiable {
		let id = UUID()
		let title: String
		let message: String
		let primaryButtonTitle: String?
		let primaryAction: (() -> Void)?
		let secondaryButtonTitle: String?
	}
	@State private var _activeAlert: ServerAlertInfo?
	
	var app: AppInfoPresentable
	@StateObject var viewModel: InstallerStatusViewModel
	@StateObject var installer: ServerInstaller
	@State var isSharing: Bool

	init(app: AppInfoPresentable, isSharing: Bool = false) {
		self.app = app
		self.isSharing = isSharing
        let method = UserDefaults.standard.integer(forKey: "Feather.installationMethod")
		let viewModel = InstallerStatusViewModel(isIdevice: method == 1)
		self._viewModel = StateObject(wrappedValue: viewModel)
		self._installer = StateObject(wrappedValue: try! ServerInstaller(app: app, viewModel: viewModel))
	}
	
	// MARK: Body
	var body: some View {
		ZStack {
			InstallProgressView(app: app, viewModel: viewModel)
			_status()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
		.sheet(isPresented: $_isWebviewPresenting) {
			SafariRepresentableView(url: installer.pageEndpoint).ignoresSafeArea()
		}
		.alert(item: $_activeAlert) { info in
			if let primaryTitle = info.primaryButtonTitle, let action = info.primaryAction {
				return Alert(
					title: Text(info.title),
					message: Text(info.message),
					primaryButton: .default(Text(primaryTitle), action: action),
					secondaryButton: .cancel(Text(info.secondaryButtonTitle ?? "Để sau"))
				)
			} else {
				return Alert(
					title: Text(info.title),
					message: Text(info.message),
					dismissButton: .default(Text("Đóng"))
				)
			}
		}
		.onReceive(viewModel.$status) { newStatus in
			if case .ready = newStatus {
				if _serverMethod == 0 {
					UIApplication.shared.open(URL(string: installer.iTunesLink)!)
				} else if _serverMethod == 1 {
					if let extUrl = URL(string: installer.iTunesLinkExternal) {
						UIApplication.shared.open(extUrl)
					} else {
						_isWebviewPresenting = true
					}
				}
				_startPayloadWatcher()
			}
            
            if case .installing = newStatus {
				payloadTimeoutTask?.cancel()
				payloadTimeoutTask = nil
                if progressTask == nil {
                    progressTask = startInstallProgressPolling(
                        bundleID: app.identifier!,
                        viewModel: viewModel
                    )
                }
            }
			
			if case .sendingPayload = newStatus {
				payloadTimeoutTask?.cancel()
				payloadTimeoutTask = nil
				if _serverMethod == 1 {
					_isWebviewPresenting = false
				}
			}
            
            switch newStatus {
            case .completed, .broken(_):
				payloadTimeoutTask?.cancel()
				payloadTimeoutTask = nil
                progressTask?.cancel()
                progressTask = nil
                BackgroundAudioManager.shared.stop()
            default:
                break
            }
		}
		.onAppear(perform: _install)
		.onAppear {
			BackgroundAudioManager.shared.start()
		}
		.onDisappear {
			payloadTimeoutTask?.cancel()
			payloadTimeoutTask = nil
            progressTask?.cancel()
            progressTask = nil
			BackgroundAudioManager.shared.stop()
		}
	}
	
	@ViewBuilder
	private func _status() -> some View {
		Label(viewModel.statusLabel, systemImage: viewModel.statusImage)
			.padding()
			.labelStyle(.titleAndIcon)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
			.animation(.smooth, value: viewModel.statusImage)
	}
	
	private func _install() {
		Task.detached {
			do {
				let handler = await ArchiveHandler(app: app, viewModel: viewModel, isSharing: isSharing)
				try await handler.move()
				
				let packageUrl = try await handler.archive()
				
				if await !isSharing {
                    if await _installationMethod == 0 {
                        await MainActor.run {
                            installer.packageUrl = packageUrl
                            viewModel.status = .ready
                        }
                        
                        if case .installing = await viewModel.status {
                            let task = await startInstallProgressPolling(
                                bundleID: app.identifier!,
                                viewModel: viewModel
                            )

                            await MainActor.run {
                                progressTask = task
                            }
                        }
                    }
                    else if await _installationMethod == 1 {
                        let handler = await InstallationProxy(viewModel: viewModel)
                        try await handler.install(at: packageUrl, suspend: app.identifier == Bundle.main.bundleIdentifier!)
                    }
                    else if await _installationMethod == 2 {
                        await MainActor.run {
                            TrollStoreHelper.install(fileUrl: packageUrl)
                            dismiss()
                        }
                    }
				} else {
					let package = try await handler.moveToArchive(packageUrl, shouldOpen: !_useShareSheet)
					
					if await !_useShareSheet {
						await MainActor.run {
							dismiss()
						}
					} else {
						if let package {
							await MainActor.run {
								dismiss()
								UIActivityViewController.show(activityItems: [package])
							}
						}
					}
				}
			} catch {
                await progressTask?.cancel()
				await MainActor.run {
					UIAlertController.showAlertWithOk(
						title: .localized("Install"),
						message: error.localizedDescription,
						action: {
							HeartbeatManager.shared.start(true)
							dismiss()
						}
					)
				}
			}
		}
	}
    private func startInstallProgressPolling(
            bundleID: String,
            viewModel: InstallerStatusViewModel
        ) -> Task<Void, Never> {

            Task.detached(priority: .background) {
                var hasStarted = false

                while !Task.isCancelled {
                    let rawProgress = await UIApplication.installProgress(for: bundleID) ?? 0.0

                    if rawProgress > 0 {
                        hasStarted = true
                    }

                    let progress = await hasStarted
                        ? _normalizeInstallProgress(rawProgress)
                        : 0.0

                    Logger.misc.info("Install progress for \(bundleID): \(progress) - \(rawProgress) - \(viewModel.installProgress)")

                    await MainActor.run {
                        viewModel.installProgress = progress
                    }

                    if hasStarted && rawProgress == 0 {
                        await MainActor.run {
                            viewModel.installProgress = 1.0
                            viewModel.status = .completed(.success(()))
                            print(viewModel.installProgress)
                        }
                        break
                    }

                    try? await Task.sleep(nanoseconds: 1_000_000) // 1 ms
                }
            }
        }

        private func _normalizeInstallProgress(_ rawProgress: Double) -> Double {
            min(1.0, max(0.0, (rawProgress - 0.6) / 0.3))
        }

	private func _startPayloadWatcher() {
		payloadTimeoutTask?.cancel()
		
		// If Semi Local is used, use a short 4.5s timeout. If Fully Local, wait 10s.
		let timeoutNanoseconds: UInt64 = (_serverMethod == 1) ? 4_500_000_000 : 10_000_000_000
		
		payloadTimeoutTask = Task { @MainActor in
			try? await Task.sleep(nanoseconds: timeoutNanoseconds)
			guard !Task.isCancelled else { return }
			
			switch viewModel.status {
			case .ready, .sendingManifest:
				if _serverMethod == 1 {
					// Auto fallback from Semi Local to Fully Local
					print("[LemonSign] Semi Local timed out (no payload request). Auto-switching to Fully Local (HTTPS)...")
					_isWebviewPresenting = false
					_serverMethod = 0
					ServerInstaller.setServerMethod(0)
					
					SSLManager.shared.autoCheckAndUpdateSSL(force: false) { [self] _ in
						do {
							try installer.restartAsFullyLocal()
							UIApplication.shared.open(URL(string: installer.iTunesLink)!)
							HapticManager.shared.impact(.medium)
						} catch {
							print("[LemonSign] Restarting as Fully Local failed, updating SSL forcefully...")
							SSLManager.shared.autoCheckAndUpdateSSL(force: true) { [self] success in
								if success {
									try? installer.restartAsFullyLocal()
									UIApplication.shared.open(URL(string: installer.iTunesLink)!)
								}
							}
						}
					}
				} else {
					// Fully Local didn't receive payload request (likely SSL expired). Auto-update SSL!
					print("[LemonSign] Fully Local payload timeout, auto-updating SSL certificates...")
					SSLManager.shared.autoCheckAndUpdateSSL(force: true) { [self] success in
						if success {
							try? installer.restartAsFullyLocal()
							UIApplication.shared.open(URL(string: installer.iTunesLink)!)
						} else {
							_activeAlert = ServerAlertInfo(
								title: "Lỗi kết nối cài đặt",
								message: "Thiết bị không thể kết nối tới máy chủ cài đặt nội bộ. Vui lòng kiểm tra lại kết nối mạng hoặc thử lại.",
								primaryButtonTitle: "Thử lại",
								primaryAction: {
									_updateSSLCertificate()
								},
								secondaryButtonTitle: "Đóng"
							)
						}
					}
				}
			default:
				break
			}
		}
	}
	
	private func _updateSSLCertificate() {
		SSLManager.shared.autoCheckAndUpdateSSL(force: true) { [self] success in
			DispatchQueue.main.async {
				if success {
					try? installer.restartAsFullyLocal()
					UIApplication.shared.open(URL(string: installer.iTunesLink)!)
				} else {
					UIAlertController.showAlertWithOk(
						title: .localized("SSL Certificates"),
						message: .localized("Failed to download, check your internet connection and try again.")
					)
				}
			}
		}
	}
}
