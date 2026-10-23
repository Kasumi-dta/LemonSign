//
//  AppIconView.swift
//  LemonSign
//
//  Created by Nagata Asami on 6/28/25.
//  Updated for LemonSign v2.0
//

import SwiftUI
import NimbleViews

// MARK: - Models
struct AppIconOption: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let alternateIconName: String?
}

// MARK: - View
struct AppIconView: View {
    @State private var selectedIcon: String? = UIApplication.shared.alternateIconName
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    private let appIcons: [AppIconOption] = [
        AppIconOption(
            id: "primary",
            title: "Pixel Lemon (Mặc định)",
            subtitle: "Quả chanh pixel vàng sáng đặc trưng LemonSign",
            iconName: "lemon_pixel",
            alternateIconName: nil
        ),
        AppIconOption(
            id: "lemon_cyber",
            title: "Cyberpunk Neon (Điện tử)",
            subtitle: "Viền dạ quang neon & bo mạch không gian tối",
            iconName: "lemon_cyber",
            alternateIconName: "lemon_cyber"
        ),
        AppIconOption(
            id: "lemon_stealth",
            title: "Stealth Carbon (Bóng đêm)",
            subtitle: "Vân sợi carbon đen nhám mạ vàng titan tối giản",
            iconName: "lemon_stealth",
            alternateIconName: "lemon_stealth"
        ),
        AppIconOption(
            id: "lemon_vapor",
            title: "Synthwave 80s (Hoàng hôn)",
            subtitle: "Màu hoàng hôn tím hồng neon retro arcade",
            iconName: "lemon_vapor",
            alternateIconName: "lemon_vapor"
        ),
        AppIconOption(
            id: "lemon_ruby",
            title: "Crimson Ruby (Huyết long)",
            subtitle: "Đá quý Ruby giác cắt hoàng gia nền rượu vang",
            iconName: "lemon_ruby",
            alternateIconName: "lemon_ruby"
        )
    ]
    
    // MARK: Body
    var body: some View {
        NBList("Biểu tượng Ứng dụng") {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "FFD60A"))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Tùy biến Màn hình chính")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Chọn phong cách biểu tượng hiển thị ngoài màn hình chính theo gu thẩm mỹ của bạn.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            NBSection("Bộ sưu tập Biểu tượng Độc quyền") {
                ForEach(appIcons) { iconOption in
                    _iconCell(for: iconOption)
                }
            } footer: {
                Text("Khi chọn biểu tượng mới, iOS sẽ hiển thị thông báo xác nhận thay đổi biểu tượng màn hình chính.")
            }
        }
        .onAppear {
            selectedIcon = UIApplication.shared.alternateIconName
        }
        .alert("Thông báo", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(successMessage)
        }
        .alert("Lỗi đổi biểu tượng", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - View extension
extension AppIconView {
    @ViewBuilder
    private func _iconCell(for iconOption: AppIconOption) -> some View {
        Button {
            _changeAppIcon(to: iconOption)
        } label: {
            HStack(spacing: 14) {
                if let image = _loadIconImage(named: iconOption.iconName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color(hex: "FFD60A").opacity(0.2))
                        .frame(width: 58, height: 58)
                        .overlay(
                            Image(systemName: "app.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                        )
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(iconOption.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(iconOption.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if selectedIcon == iconOption.alternateIconName {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "FFD60A"))
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func _loadIconImage(named name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "AppIcons"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        if let defaultName = Bundle.main.iconFileName, let image = UIImage(named: defaultName) {
            return image
        }
        return nil
    }
    
    private func _changeAppIcon(to iconOption: AppIconOption) {
        guard selectedIcon != iconOption.alternateIconName else { return }
        
        guard UIApplication.shared.supportsAlternateIcons else {
            errorMessage = "Thiết bị không hỗ trợ đổi biểu tượng thay thế."
            showErrorAlert = true
            return
        }
        
        UIApplication.shared.setAlternateIconName(iconOption.alternateIconName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[AppIcon] Failed to change app icon: \(error.localizedDescription)")
                    self.errorMessage = "Không thể đổi biểu tượng: \(error.localizedDescription)"
                    self.showErrorAlert = true
                } else {
                    self.selectedIcon = iconOption.alternateIconName
                    self.successMessage = "Đã chuyển sang biểu tượng: \(iconOption.title)"
                    self.showSuccessAlert = true
                }
            }
        }
    }
}
