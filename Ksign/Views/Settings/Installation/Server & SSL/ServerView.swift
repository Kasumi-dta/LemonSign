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
	@State private var _sslLastUpdatedText: String = ""
	@State private var _sslStatusBadgeText: String = "Bản mới nhất"
	@State private var _isSslUpToDate: Bool = true
	@State private var _sslVersionText: String = "v1.0"
	@State private var _sslDomainText: String = "localhost.backloop.dev"
	
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
					Label("Trạng thái chứng chỉ", systemImage: "shield.lefthalf.filled")
					Spacer()
					HStack(spacing: 6) {
						Circle()
							.fill(_isSslUpToDate ? Color.green : Color.orange)
							.frame(width: 8, height: 8)
						Text(_sslStatusBadgeText)
							.font(.footnote)
							.fontWeight(.semibold)
							.foregroundColor(_isSslUpToDate ? .green : .orange)
					}
				}
				
				HStack {
					Label("Phiên bản SSL", systemImage: "checkmark.seal.fill")
					Spacer()
					Text(_sslVersionText)
						.font(.footnote)
						.foregroundColor(.secondary)
				}
				
				HStack {
					Label("Thời gian cập nhật", systemImage: "clock.arrow.circlepath")
					Spacer()
					Text(_sslLastUpdatedText.isEmpty ? "Mặc định (Chưa cập nhật)" : _sslLastUpdatedText)
						.font(.footnote)
						.foregroundColor(.secondary)
				}
				
				HStack {
					Label("Hạn sử dụng", systemImage: "calendar.badge.clock")
					Spacer()
					Text(_sslExpirationText.isEmpty ? "Tự động gia hạn" : _sslExpirationText)
						.font(.footnote)
						.foregroundColor(.secondary)
				}
				
				HStack {
					Label("Tên miền hỗ trợ", systemImage: "network")
					Spacer()
					Text(_sslDomainText)
						.font(.caption)
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
			} header: {
				Text("Chứng chỉ SSL HTTPS Nội bộ")
			} footer: {
				Text("Chứng chỉ SSL Let's Encrypt cho localhost.backloop.dev bảo đảm cài đặt OTA nội bộ không bao giờ bị Apple chặn. Khi có bản cập nhật mới, bấm nút trên để tải và đồng bộ thời gian ngay.")
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
		guard SSLManager.shared.isSSLCertificatePresent(),
			  let expDate = SSLManager.shared.sslExpirationDate() else {
			_isSslUpToDate = false
			_sslStatusBadgeText = "Cần cập nhật"
			_sslExpirationText = "Chưa có chứng chỉ"
			_sslVersionText = "Chưa cài đặt"
			_sslLastUpdatedText = "Chưa cập nhật"
			_sslDomainText = "localhost.backloop.dev"
			return
		}
		
		let isExpired = expDate <= Date()
		_isSslUpToDate = !isExpired
		_sslStatusBadgeText = !isExpired ? "Bản mới nhất" : "Cần cập nhật (Đã hết hạn)"
		_sslVersionText = "v\(SSLManager.shared.sslVersion()) (Let's Encrypt)"
		_sslDomainText = SSLManager.shared.commonNameString()
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy"
		_sslExpirationText = "HSD: \(formatter.string(from: expDate))"
		
		if let updateDate = SSLManager.shared.lastUpdatedDate() {
			let formatter = DateFormatter()
			formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
			_sslLastUpdatedText = formatter.string(from: updateDate)
		} else {
			_sslLastUpdatedText = "Mặc định ban đầu"
		}
	}
	
	private func _updateSSL() {
		_isUpdatingSSL = true
		SSLManager.shared.autoCheckAndUpdateSSL(force: true) { success in
			DispatchQueue.main.async {
				_isUpdatingSSL = false
				_refreshSSLStatus()
				if success {
					let now = DateFormatter()
					now.dateFormat = "HH:mm:ss dd/MM/yyyy"
					let timeStr = now.string(from: Date())
					UIAlertController.showAlertWithOk(
						title: "Chứng chỉ SSL đã cập nhật",
						message: "Đã tải và cài đặt bản SSL mới nhất thành công lúc \(timeStr)!\n\nTrạng thái: Bản mới nhất\nTên miền: \(_sslDomainText)"
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
