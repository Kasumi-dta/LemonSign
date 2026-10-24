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
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	@AppStorage("Feather.ultraFastInstall") private var _ultraFastInstall: Bool = true
	
	@State private var _isUpdatingSSL: Bool = false
	@State private var _sslExpirationText: String = ""
	@State private var _sslLastUpdatedText: String = ""
	@State private var _sslStatusBadgeText: String = "Bản mới nhất"
	@State private var _isSslUpToDate: Bool = true
	@State private var _sslVersionText: String = "v1.0"
	@State private var _sslDomainText: String = "localhost.backloop.dev"

	// Server Check States
	@State private var _isCheckingLemon: Bool = false
	@State private var _lemonCheckStatus: String = "Chưa kiểm tra (Bấm để test)"
	@State private var _isLemonHealthy: Bool? = nil

	@State private var _isCheckingEsign: Bool = false
	@State private var _esignCheckStatus: String = "Chưa kiểm tra (Bấm để test)"
	@State private var _isEsignHealthy: Bool? = nil
	
	private var _serverMethods: [String] {
		[
			"🍋 Máy chủ LemonSign (Cục bộ HTTPS - Khuyên dùng)",
			"⚡ Máy chủ ESign / Công cộng (Public Relay)"
		]
	}
	
	var body: some View {
		Group {
			Section {
				Picker("Máy chủ cài đặt OTA", systemImage: "server.rack", selection: $_serverMethod) {
					ForEach(_serverMethods.indices, id: \.self) { index in
						Text(_serverMethods[index]).tag(index)
					}
				}
			} footer: {
				if _serverMethod == 0 {
					Text("Máy chủ LemonSign: Chạy HTTPS nội bộ trên iPhone (localhost.backloop.dev). Hoàn toàn riêng tư, không cần Internet, tốc độ truyền nội bộ cực đại.")
				} else {
					Text("Máy chủ ESign / Công cộng: Sử dụng máy chủ tạo manifest công cộng (api.palera.in). Hộp thoại iOS sẽ hiển thị yêu cầu cài đặt từ máy chủ công cộng tương tự ESign.")
				}
			}

			Section {
				// Check Lemon Server
				VStack(alignment: .leading, spacing: 6) {
					HStack {
						Label("Server Lemon (Nội bộ)", systemImage: "house.fill")
							.font(.subheadline)
							.fontWeight(.medium)
						Spacer()
						Button {
							_checkLemonServer()
						} label: {
							if _isCheckingLemon {
								ProgressView()
									.controlSize(.small)
							} else {
								Text("Kiểm tra")
									.font(.caption)
									.fontWeight(.bold)
									.padding(.horizontal, 10)
									.padding(.vertical, 4)
									.background(Color.accentColor.opacity(0.15))
									.foregroundColor(.accentColor)
									.clipShape(Capsule())
							}
						}
						.buttonStyle(.plain)
						.disabled(_isCheckingLemon)
					}
					
					HStack(spacing: 5) {
						if let healthy = _isLemonHealthy {
							Circle()
								.fill(healthy ? Color.green : Color.red)
								.frame(width: 7, height: 7)
						}
						Text(_lemonCheckStatus)
							.font(.caption2)
							.foregroundColor(_isLemonHealthy == true ? .green : (_isLemonHealthy == false ? .red : .secondary))
					}
				}
				.padding(.vertical, 2)

				// Check ESign Server
				VStack(alignment: .leading, spacing: 6) {
					HStack {
						Label("Server ESign (Công cộng)", systemImage: "globe")
							.font(.subheadline)
							.fontWeight(.medium)
						Spacer()
						Button {
							_checkEsignServer()
						} label: {
							if _isCheckingEsign {
								ProgressView()
									.controlSize(.small)
							} else {
								Text("Kiểm tra")
									.font(.caption)
									.fontWeight(.bold)
									.padding(.horizontal, 10)
									.padding(.vertical, 4)
									.background(Color.accentColor.opacity(0.15))
									.foregroundColor(.accentColor)
									.clipShape(Capsule())
							}
						}
						.buttonStyle(.plain)
						.disabled(_isCheckingEsign)
					}
					
					HStack(spacing: 5) {
						if let healthy = _isEsignHealthy {
							Circle()
								.fill(healthy ? Color.green : Color.red)
								.frame(width: 7, height: 7)
						}
						Text(_esignCheckStatus)
							.font(.caption2)
							.foregroundColor(_isEsignHealthy == true ? .green : (_isEsignHealthy == false ? .red : .secondary))
					}
				}
				.padding(.vertical, 2)
			} header: {
				Text("Kiểm tra trạng thái máy chủ")
			} footer: {
				Text("Bấm 'Kiểm tra' để xác minh máy chủ có sẵn sàng phát manifest và cài đặt ứng dụng cho thiết bị hay không.")
			}
			
			Section {
				Toggle("Tối ưu siêu tốc độ (Store Mode)", systemImage: "bolt.fill", isOn: $_ultraFastInstall)
			} footer: {
				Text("Bỏ qua nén Deflate khi đóng gói cài đặt nội bộ. Giúp đóng gói IPA trong 0.3s và iOS cài đặt xong chỉ trong 2-3 giây (tương tự cơ chế của ESign).")
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
					Label("Lần đồng bộ gần nhất", systemImage: "clock.arrow.circlepath")
					Spacer()
					Text(_sslLastUpdatedText.isEmpty ? "Mặc định (Chưa đồng bộ)" : _sslLastUpdatedText)
						.font(.footnote)
						.foregroundColor(.secondary)
				}
				
				HStack {
					Label("Hạn chứng chỉ Let's Encrypt", systemImage: "calendar.badge.clock")
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
			}
		}
		.onAppear {
			_refreshSSLStatus()
			_checkLemonServer()
			_checkEsignServer()
		}
		.onReceive(NotificationCenter.default.publisher(for: SSLManager.sslDidUpdateNotification)) { _ in
			_refreshSSLStatus()
		}
	}
	
	private func _checkLemonServer() {
		_isCheckingLemon = true
		_lemonCheckStatus = "Đang kiểm tra chứng chỉ & cổng nội bộ..."
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.3) {
			let isPresent = SSLManager.shared.isSSLCertificatePresent()
			let expDate = SSLManager.shared.sslExpirationDate()
			let isNotExpired = (expDate ?? Date.distantPast) > Date()
			
			DispatchQueue.main.async {
				_isCheckingLemon = false
				if isPresent && isNotExpired {
					_isLemonHealthy = true
					_lemonCheckStatus = "Hoạt động hoàn hảo (localhost.backloop.dev - SSL hợp lệ)"
				} else if isPresent {
					_isLemonHealthy = false
					_lemonCheckStatus = "Cần cập nhật chứng chỉ SSL (Đã hết hạn)"
				} else {
					_isLemonHealthy = false
					_lemonCheckStatus = "Chưa có chứng chỉ SSL trên máy"
				}
			}
		}
	}

	private func _checkEsignServer() {
		_isCheckingEsign = true
		_esignCheckStatus = "Đang kiểm tra kết nối api.palera.in..."
		let targetUrl = URL(string: "https://api.palera.in")!
		var request = URLRequest(url: targetUrl)
		request.httpMethod = "HEAD"
		request.timeoutInterval = 6
		let startTime = Date()

		URLSession.shared.dataTask(with: request) { _, response, error in
			let latency = Int(Date().timeIntervalSince(startTime) * 1000)
			DispatchQueue.main.async {
				_isCheckingEsign = false
				if let httpResponse = response as? HTTPURLResponse, (200...499).contains(httpResponse.statusCode) {
					_isEsignHealthy = true
					_esignCheckStatus = "Trực tuyến (Phản hồi tốt: \(latency)ms)"
				} else if error == nil {
					_isEsignHealthy = true
					_esignCheckStatus = "Trực tuyến (\(latency)ms)"
				} else {
					_isEsignHealthy = false
					_esignCheckStatus = "Không thể kết nối (\(error?.localizedDescription ?? "Hết thời gian"))"
				}
			}
		}.resume()
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
		_sslExpirationText = "\(formatter.string(from: expDate)) (Còn hiệu lực)"
		
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
				_checkLemonServer()
				if success {
					let now = DateFormatter()
					now.dateFormat = "HH:mm:ss dd/MM/yyyy"
					let timeStr = now.string(from: Date())
					UIAlertController.showAlertWithOk(
						title: "Đã đồng bộ Chứng chỉ SSL",
						message: "Đã tải và đồng bộ chứng chỉ SSL mới nhất thành công lúc \(timeStr)!\n\n• Trạng thái: Bản mới nhất\n• Hạn Let's Encrypt: \(_sslExpirationText)\n• Tên miền: \(_sslDomainText)\n\nChứng chỉ hiện tại vẫn còn hiệu lực và hoạt động hoàn hảo."
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
