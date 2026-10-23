//
//  ServerView.swift
//  Feather
//
//  Created by samara on 6.05.2025.
//

import SwiftUI
import NimbleJSON
import NimbleViews

struct ServerView: View {
	@AppStorage("Feather.ipFix") private var _ipFix: Bool = false
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	@State private var _isUpdatingSSL: Bool = false
	@State private var _sslExpirationText: String = ""
	
	private var _serverMethods: [String] {
		[
			.localized("Fully Local") + (ServerInstaller.isHighIOS ? " (Mặc định iOS 17+)" : " (Khuyên dùng)"),
			.localized("Semi Local") + " (iOS cũ)"
		]
	}
	
	var body: some View {
		Group {
			Section {
				Picker(.localized("Installation Type"), systemImage: "server.rack", selection: $_serverMethod) {
					ForEach(_serverMethods.indices, id: \.self) { index in
						Text(_serverMethods[index]).tag(index)
					}
				}
				Toggle(.localized("Only use localhost address"), systemImage: "lifepreserver", isOn: $_ipFix)
					.disabled(_serverMethod != 1)
			} footer: {
				if ServerInstaller.isHighIOS {
					Text("Trên iOS 17 trở lên, LemonSign tự động ưu tiên Cục bộ hoàn toàn (Fully Local HTTPS). Chế độ Bán cục bộ (Semi Local) sẽ tự động chuyển đổi sang Cục bộ hoàn toàn nếu gặp lỗi mạng.")
				}
			}
			
			Section {
				HStack {
					Label("Chứng chỉ SSL nội bộ", systemImage: "lock.shield")
					Spacer()
					Text(_sslExpirationText.isEmpty ? "Tự động gia hạn" : _sslExpirationText)
						.font(.footnote)
						.foregroundColor(.secondary)
				}
				
				Button {
					_updateSSL()
				} label: {
					HStack {
						Label(.localized("Update SSL Certificates"), systemImage: "arrow.clockwise")
						if _isUpdatingSSL {
							Spacer()
							ProgressView()
						}
					}
				}
				.disabled(_isUpdatingSSL)
			} footer: {
				Text("Chứng chỉ SSL Let's Encrypt cho *.backloop.dev được tự động kiểm tra và cập nhật ngầm khi mở app hoặc khi cài đặt.")
			}
		}
		.onAppear(perform: _refreshSSLStatus)
		.onReceive(NotificationCenter.default.publisher(for: SSLManager.sslDidUpdateNotification)) { _ in
			_refreshSSLStatus()
		}
		.onChange(of: _serverMethod) { newValue in
			if ServerInstaller.isHighIOS && newValue == 1 {
				UIAlertController.showAlertWithOk(
					title: "Lưu ý iOS 17+",
					message: "Trên iOS 17 trở lên, chế độ Bán cục bộ (Semi Local) thường bị Apple chặn tải qua HTTP. LemonSign sẽ tự động chuyển sang Cục bộ hoàn toàn nếu phát hiện lỗi."
				)
			} else {
				UIAlertController.showAlertWithRestart(
					title: .localized("Restart Required"),
					message: .localized("These changes require a restart of the app")
				)
			}
		}
	}
	
	private func _refreshSSLStatus() {
		if let date = SSLManager.shared.sslExpirationDate() {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .none
			_sslExpirationText = "HSD: \(formatter.string(from: date))"
		} else {
			_sslExpirationText = "Tự động gia hạn"
		}
	}
	
	private func _updateSSL() {
		_isUpdatingSSL = true
		SSLManager.shared.autoCheckAndUpdateSSL(force: true) { success in
			DispatchQueue.main.async {
				_isUpdatingSSL = false
				_refreshSSLStatus()
				if success {
					UIAlertController.showAlertWithOk(
						title: .localized("SSL Certificates"),
						message: .localized("SSL certificates updated successfully! Please restart the app or try installing again.")
					)
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
