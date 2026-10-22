//
//  SettingsDonationCellView.swift
//  LemonSign
//
//  Created by samara on 30.04.2025.
//  Customized for LemonSign 3105 on 22.10.2026.
//

import SwiftUI
import NimbleViews

struct SystemInfoItem: Identifiable {
	let id = UUID()
	let title: String
	let message: String
}

struct SettingsDonationCellView: View {
	var site: String
	
	@State private var _selectedInfo: SystemInfoItem? = nil
	private var _isJailbroken: Bool {
		JailbreakDetector.isJailbroken
	}
	
	var body: some View {
		Section {
			VStack(spacing: 14) {
				_brandHeader()
				
				_statusPills()
				
				Button {
					UIApplication.open(site)
				} label: {
					HStack(spacing: 8) {
						Image(systemName: "heart.fill")
							.font(.subheadline)
							.foregroundStyle(.black)
						Text(.localized("Show Your Support"))
							.font(.subheadline.bold())
							.foregroundStyle(.black)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 38)
					.background(Color.accentColor)
					.clipShape(Capsule())
				}
				.buttonStyle(.plain)
			}
			.padding(.vertical, 8)
		}
		.alert(item: $_selectedInfo) { item in
			Alert(
				title: Text(item.title),
				message: Text(item.message),
				dismissButton: .default(Text("Đã hiểu"))
			)
		}
	}
	
	@ViewBuilder
	private func _brandHeader() -> some View {
		HStack(spacing: 14) {
			if let img = UIImage(named: "lemon_pixel") ?? UIImage(named: "AppIcon") {
				Image(uiImage: img)
					.appIconStyle(size: 60)
			} else {
				Image(systemName: "slider.horizontal.3")
					.font(.title)
					.foregroundStyle(Color.accentColor)
					.frame(width: 60, height: 60)
					.background(Color.accentColor.opacity(0.15))
					.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}
			
			VStack(alignment: .leading, spacing: 3) {
				HStack(spacing: 6) {
					Text("LemonSign")
						.font(.title3.bold())
					
					Text("3105")
						.font(.caption2.bold())
						.foregroundStyle(.black)
						.padding(.horizontal, 6)
						.padding(.vertical, 2)
						.background(Color.accentColor)
						.clipShape(Capsule())
				}
				
				Text("v\(Bundle.main.version) • On-Device Signer")
					.font(.caption)
					.foregroundStyle(.secondary)
				
				Text("Powered by Zsign & Vapor Engine")
					.font(.caption2)
					.foregroundStyle(.tertiary)
			}
			
			Spacer()
		}
	}
	
	@ViewBuilder
	private func _statusPills() -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				_pill(
					icon: "apple.logo",
					title: "iOS \(UIDevice.current.systemVersion)"
				) {
					_selectedInfo = SystemInfoItem(
						title: "Hệ điều hành iOS",
						message: "Phiên bản: iOS \(UIDevice.current.systemVersion) (\(UIDevice.current.model)). LemonSign tương thích và hoạt động ổn định từ iOS 14.0 trở lên."
					)
				}
				
				_pill(
					icon: _isJailbroken ? "lock.open.fill" : "lock.shield.fill",
					title: _isJailbroken ? "Đã Jailbreak" : "Chưa JB",
					badgeColor: _isJailbroken ? Color.green.opacity(0.18) : nil,
					textColor: _isJailbroken ? .green : .secondary
				) {
					_selectedInfo = SystemInfoItem(
						title: _isJailbroken ? "Trạng thái: Đã Jailbreak (JB)" : "Trạng thái: Chưa Jailbreak (Stock)",
						message: _isJailbroken
							? "Thiết bị của bạn đã được Jailbreak (Rootless hoặc Rootful). Bạn có thể ký, cài đặt app hoặc tiêm các tweak/dylib hệ thống hoàn toàn tự do."
							: "Thiết bị đang chạy iOS nguyên bản (chưa bẻ khóa). LemonSign sử dụng chứng chỉ cá nhân (.p12) để sideload ứng dụng an toàn mà không cần can thiệp hệ thống."
					)
				}
				
				_pill(
					icon: "cpu",
					title: "Offline Engine"
				) {
					_selectedInfo = SystemInfoItem(
						title: "Trình ký ngoại tuyến (Offline Engine)",
						message: "Toàn bộ quá trình giải mã, băm SHA và ký chứng chỉ P12 được xử lý 100% bằng engine C++ Zsign ngay trên chip thiết bị mà không cần kết nối mạng. Chứng chỉ và file IPA của bạn được bảo mật tuyệt đối, không bao giờ bị tải lên máy chủ bên thứ 3."
					)
				}
				
				_pill(
					icon: "checkmark.shield",
					title: "Safe Install"
				) {
					_selectedInfo = SystemInfoItem(
						title: "Cài đặt an toàn (Safe Install)",
						message: "LemonSign khởi chạy máy chủ mini HTTPS chạy ngầm cục bộ (Localhost OTA) và hỗ trợ IDevice Tunnel trực tiếp trên thiết bị để cài app đã ký lên màn hình chính an toàn, không lo lỗi chứng chỉ mạng trung gian."
					)
				}
			}
			.padding(.horizontal, 2)
		}
	}
	
	@ViewBuilder
	private func _pill(
		icon: String,
		title: String,
		badgeColor: Color? = nil,
		textColor: Color = .secondary,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			HStack(spacing: 4) {
				Image(systemName: icon)
					.font(.system(size: 10, weight: .semibold))
				Text(title)
					.font(.system(size: 11, weight: .medium))
			}
			.padding(.horizontal, 8)
			.padding(.vertical, 5)
			.background(badgeColor ?? Color(uiColor: .secondarySystemFill))
			.clipShape(Capsule())
			.foregroundStyle(textColor)
		}
		.buttonStyle(.plain)
	}
}
