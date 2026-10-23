//
//  SettingsView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct SettingsView: View {
	@Environment(\.dismiss) private var dismiss
    @AppStorage("feather.selectedCert") private var _storedSelectedCert: Int = 0
    @FetchRequest(
        entity: CertificatePair.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
        animation: .snappy
    ) private var _certificates: FetchedResults<CertificatePair>
    
    private var selectedCertificate: CertificatePair? {
        guard
            _storedSelectedCert >= 0,
            _storedSelectedCert < _certificates.count
        else {
            return nil
        }
        return _certificates[_storedSelectedCert]
    }
    
    
	private let _donationsUrl = "https://github.com/sponsors/Kasumi-dta"
	private let _githubUrl = "https://github.com/Kasumi-dta"
	// MARK: Body
    var body: some View {
		NBNavigationView(.localized("Settings")) {
			Form {
//				#if !NIGHTLY && !DEBUG
				SettingsDonationCellView(site: _donationsUrl)
//				#endif
				
				_feedback()
				
				Section {
					NavigationLink(destination: AppearanceView()) {
                        Label(.localized("Appearance"), systemImage: "paintbrush")
                    }
					NavigationLink(destination: AlternateIconView()) {
                        Label("Biểu tượng Ứng dụng", systemImage: "app.dashed")
                    }
				}
                
                NBSection("Công cụ Sideload & Hệ thống") {
                    NavigationLink(destination: ThreeOneOSFiveView()) {
                        HStack {
                            Label("Bộ công cụ 3105", systemImage: "puzzlepiece.extension.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                            Spacer()
                            Text("MobileGestalt & Lab")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    NavigationLink(destination: AntiRevokeView()) {
                        Label("Lá chắn Chống Thu hồi", systemImage: "shield.lefthalf.filled")
                    }
                    NavigationLink(destination: TweakHubView()) {
                        Label("Kho Tweak & Dylib", systemImage: "sparkles.rectangle.stack.fill")
                    }
                    NavigationLink(destination: AirShareView()) {
                        Label("AirShare WiFi & QR", systemImage: "wifi.circle.fill")
                    }
                } footer: {
                    Text("Bộ công cụ mở rộng: 3105, Lá chắn chặn thu hồi chứng chỉ, thư viện tweak tiêm tự động và chia sẻ không dây.")
                }
                
                NBSection(.localized("Certificates")) {
                    NavigationLink(destination: CertificatesView()) {
                        HStack {
                            Label(.localized("Certificates"), systemImage: "signature")
                            Spacer()
                            Text("\(_certificates.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let cert = selectedCertificate {
                        CertificatesCellView(cert: cert)
                    } else {
                        Text(.localized("No Certificate"))
                            .font(.footnote)
                            .foregroundColor(.disabled())
                    }
                } footer: {
                    Text(.localized("Add and manage certificates used for signing applications."))
                }
				
				NBSection(.localized("Features")) {
                    NavigationLink(destination: LogsView(manager: LogsManager.shared)) {
                        Label(.localized("Logs"), systemImage: "apple.terminal")
                    }
					NavigationLink(destination: AppFeaturesView()) {
                        Label(.localized("App Features"), systemImage: "sparkles")
                    }
					NavigationLink(destination: ConfigurationView()) {
                        Label(.localized("Signing Options"), systemImage: "gear")
                    }
					NavigationLink(destination: ArchiveView()) {
                        Label(.localized("Archive & Extraction"), systemImage: "archivebox")
                    }
					NavigationLink(destination: InstallationView()) {
                        Label(.localized("Installation"), systemImage: "server.rack")
                    }
				}
				
				_directories()
                
                Section {
                    NavigationLink(destination: ResetView()) {
                        Label(.localized("Reset"), systemImage: "trash")
                    }
                } footer: {
                    Text("Reset the applications sources, certificates, apps, and general contents.")
                }

            }
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(.localized("Done")) {
						dismiss()
					}
					.fontWeight(.bold)
					.foregroundColor(Color(hex: "DDA200"))
				}
			}
        }
    }
}

// MARK: - View extension
extension SettingsView {
	@ViewBuilder
	private func _feedback() -> some View {
		Section {
			NavigationLink(destination: AboutNyaView()) {
                Label(.localized("About"), systemImage: "info.circle")
            }
			Button(.localized("Check for Updates"), systemImage: "arrow.triangle.2.circlepath.circle") {
				UpdateManager.shared.checkForUpdates(isManualCheck: true)
			}
			Button(.localized("Telegram Channel"), systemImage: "paperplane.circle") {
				UIApplication.open("https://t.me/applep12vnn")
			}
			Button(.localized("GitHub Repository"), systemImage: "safari") {
				UIApplication.open(_githubUrl)
			}
		}
	}
	
	@ViewBuilder
	private func _directories() -> some View {
		NBSection(.localized("Misc")) {
			Button(.localized("Open Documents"), systemImage: "folder") {
				UIApplication.open(URL.documentsDirectory.toSharedDocumentsURL()!)
			}
			Button(.localized("Open Archives"), systemImage: "folder") {
				UIApplication.open(FileManager.default.archives.toSharedDocumentsURL()!)
			}
		} footer: {
			Text(.localized("All of LemonSign files except certificates are contained in the documents directory, here are some quick links to these."))
		}
	}
}
