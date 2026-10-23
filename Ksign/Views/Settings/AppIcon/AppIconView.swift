//
//  AppIconView.swift
//  Ksign
//
//  Created by Nagata Asami on 6/28/25.
//

import SwiftUI
import NimbleViews

// MARK: - Models
struct AppIconOption {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let alternateIconName: String?
}

// MARK: - View
struct AppIconView: View {
    @State private var selectedIcon: String? = UIApplication.shared.alternateIconName
    
    private let appIcons: [AppIconOption] = [
        AppIconOption(
            id: "primary",
            title: "Pixel Lemon (Mặc định)",
            subtitle: "Quả chanh pixel vàng sáng đặc trưng",
            iconName: "AppIcon",
            alternateIconName: nil
        ),
        AppIconOption(
            id: "lemon_pixel",
            title: "Pixel Lemon Retro",
            subtitle: "Lemon Yellow Pixel Art",
            iconName: "lemon_pixel",
            alternateIconName: "lemon_pixel"
        ),
        AppIconOption(
            id: "cyber",
            title: "Cyber Dark",
            subtitle: "Giao diện bóng tối viền dạ quang neon",
            iconName: "AppIconCyber",
            alternateIconName: "AppIconCyber"
        ),
        AppIconOption(
            id: "neon",
            title: "Glitch Neon",
            subtitle: "Nghệ thuật tương lai tách màu RGB",
            iconName: "AppIconNeon",
            alternateIconName: "AppIconNeon"
        ),
        AppIconOption(
            id: "stealth",
            title: "Stealth Calculator",
            subtitle: "Ngụy trang máy tính bảo vệ riêng tư",
            iconName: "AppIconStealth",
            alternateIconName: "AppIconStealth"
        )
    ]
    
    // MARK: Body
    var body: some View {
        NBList(.localized("App Icon")) {
            NBSection(.localized("Available Icons")) {
                ForEach(appIcons, id: \.id) { iconOption in
                    _iconCell(for: iconOption)
                }
            }
        }
        .onAppear {
            selectedIcon = UIApplication.shared.alternateIconName
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
            HStack(spacing: 12) {
                if let image = UIImage(named: iconOption.iconName) ?? UIImage(named: Bundle.main.iconFileName ?? "") {
                    Image(uiImage: image)
                        .appIconStyle(size: 60)
                } else {
                    Image("App_Unknown")
                        .appIconStyle(size: 60)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(iconOption.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(iconOption.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if selectedIcon == iconOption.alternateIconName {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                        .font(.headline)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func _changeAppIcon(to iconOption: AppIconOption) {
        guard selectedIcon != iconOption.alternateIconName else { return }
        
//        guard UIApplication.shared.supportsAlternateIcons else {
//            print("Alternate icons are not supported on this device")
//            return
//        }
        
        UIApplication.shared.setAlternateIconName(iconOption.alternateIconName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to change app icon: \(error.localizedDescription)")
                } else {
                    self.selectedIcon = iconOption.alternateIconName
                    print("Successfully changed app icon to: \(iconOption.alternateIconName ?? "primary")")
                }
            }
        }
    }
} 
