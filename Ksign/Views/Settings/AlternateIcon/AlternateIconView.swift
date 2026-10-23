//
//  AlternateIconView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct AppIconOption: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let iconAsset: String? // nil for default
    let previewColor: Color
}

struct AlternateIconView: View {
    @AppStorage("lemonsign.selectedIcon") private var selectedIconId: String = "default"
    @State private var currentAppIcon: String? = UIApplication.shared.alternateIconName
    
    let icons: [AppIconOption] = [
        AppIconOption(
            id: "default",
            name: "Pixel Lemon (Mặc định)",
            subtitle: "Quả chanh pixel vàng sáng đặc trưng LemonSign",
            iconAsset: nil,
            previewColor: Color(hex: "FFD60A")
        ),
        AppIconOption(
            id: "AppIconCyber",
            name: "Cyber Dark",
            subtitle: "Giao diện bóng tối viền dạ quang vàng neon",
            iconAsset: "AppIconCyber",
            previewColor: Color.black
        ),
        AppIconOption(
            id: "AppIconNeon",
            name: "Glitch Neon",
            subtitle: "Nghệ thuật tương lai với hiệu ứng tách màu RGB",
            iconAsset: "AppIconNeon",
            previewColor: Color.cyan
        ),
        AppIconOption(
            id: "AppIconRetro",
            name: "Retro Classic Apple",
            subtitle: "Họa tiết sọc cầu vồng thập niên 80 hoài niệm",
            iconAsset: "AppIconRetro",
            previewColor: Color.orange
        ),
        AppIconOption(
            id: "AppIconStealth",
            name: "Stealth Calculator (Ngụy trang)",
            subtitle: "Biểu tượng máy tính bỏ túi bảo vệ sự riêng tư",
            iconAsset: "AppIconStealth",
            previewColor: Color.gray
        )
    ]
    
    var body: some View {
        NBList("Biểu tượng Ứng dụng") {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "FFD60A"))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Tùy biến Màn hình chính")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Chọn giao diện icon hiển thị ngoài màn hình chính theo phong cách riêng của bạn.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section("Bộ sưu tập Icon") {
                ForEach(icons) { icon in
                    Button {
                        _setIcon(icon)
                    } label: {
                        HStack(spacing: 14) {
                            // Icon Preview Card
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(icon.previewColor.opacity(0.85))
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                                
                                if icon.id == "default" {
                                    Text("🍋")
                                        .font(.system(size: 26))
                                } else if icon.id == "AppIconCyber" {
                                    Image(systemName: "bolt.shield.fill")
                                        .font(.title2)
                                        .foregroundColor(Color(hex: "FFD60A"))
                                } else if icon.id == "AppIconNeon" {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                } else if icon.id == "AppIconRetro" {
                                    Image(systemName: "applelogo")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                } else if icon.id == "AppIconStealth" {
                                    Image(systemName: "plus.forwardslash.minus")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(icon.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text(icon.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if (currentAppIcon == nil && icon.iconAsset == nil) || (currentAppIcon == icon.iconAsset) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "FFD60A"))
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } footer: {
                Text("Khi thay đổi biểu tượng, hệ điều hành iOS có thể hiển thị một thông báo xác nhận ngắn ngoài màn hình chính.")
            }
        }
        .onAppear {
            currentAppIcon = UIApplication.shared.alternateIconName
        }
    }
    
    private func _setIcon(_ icon: AppIconOption) {
        guard UIApplication.shared.supportsAlternateIcons else {
            UIAlertController.showAlertWithOk(
                title: "Không hỗ trợ",
                message: "Thiết bị này không hỗ trợ tính năng đổi biểu tượng ứng dụng."
            )
            return
        }
        
        // Haptic feedback only, NO sound effect per user request
        HapticManager.shared.impact(.medium)
        
        let targetName = icon.iconAsset
        UIApplication.shared.setAlternateIconName(targetName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[AlternateIcon] Failed to set icon: \(error.localizedDescription)")
                } else {
                    currentAppIcon = targetName
                    selectedIconId = icon.id
                }
            }
        }
    }
}
