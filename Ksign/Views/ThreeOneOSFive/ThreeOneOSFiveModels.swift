//
//  ThreeOneOSFiveModels.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import Foundation
import SwiftUI

enum ThreeOnePackageKind: String, CaseIterable, Identifiable {
    case all = "Tất cả"
    case patch = "Bản vá .3105"
    case dialerTheme = "Theme bàn phím"
    case wallpaper = "Hình nền Poster"
    case tool = "Công cụ"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .patch: return "puzzlepiece.extension.fill"
        case .dialerTheme: return "phone.circle.fill"
        case .wallpaper: return "photo.stack.fill"
        case .tool: return "wrench.and.screwdriver.fill"
        }
    }
}

struct ThreeOnePackage: Identifiable, Hashable {
    let id: String
    let name: String
    let author: String
    let kind: ThreeOnePackageKind
    let description: String
    let version: String
    let iconSystemName: String
    let accentColor: Color
    var isInstalled: Bool = false
    let targetApp: String?
}

final class ThreeOneStore: ObservableObject {
    static let shared = ThreeOneStore()
    
    @Published var packages: [ThreeOnePackage] = [
        ThreeOnePackage(
            id: "dock.transparency",
            name: "Transparent Dock",
            author: "YangJiii",
            kind: .patch,
            description: "Bản vá làm trong suốt nền thanh Dock trên màn hình chính cho iOS 17 và iOS 18.",
            version: "1.2",
            iconSystemName: "rectangle.bottomthird.inset.filled",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: false,
            targetApp: "SpringBoard"
        ),
        ThreeOnePackage(
            id: "hide.icon.labels",
            name: "Hide App Labels",
            author: "0xjohnny",
            kind: .patch,
            description: "Ẩn toàn bộ tên nhãn chữ dưới biểu tượng ứng dụng trên màn hình chính, mang lại giao diện tối giản.",
            version: "1.0",
            iconSystemName: "text.badge.minus",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: false,
            targetApp: "SpringBoard"
        ),
        ThreeOnePackage(
            id: "enable.supervised",
            name: "Supervised Mode Activator",
            author: "YangJiii",
            kind: .tool,
            description: "Kích hoạt cờ Giám sát (Supervised Mode) cho thiết bị mà không cần máy tính hoặc khôi phục cài đặt gốc.",
            version: "2.1",
            iconSystemName: "lock.shield.fill",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: false,
            targetApp: "System Preferences"
        ),
        ThreeOnePackage(
            id: "dialer.neon.cyber",
            name: "Neon Glow Dialer",
            author: "duongduong0908",
            kind: .dialerTheme,
            description: "Bộ giao diện bàn phím gọi điện thoại .3105pass phát sáng dạ quang màu vàng chanh hiện đại.",
            version: "2.0",
            iconSystemName: "phone.bubble.fill",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: false,
            targetApp: "MobilePhone"
        ),
        ThreeOnePackage(
            id: "dialer.oled.minimal",
            name: "Minimal OLED Black",
            author: "CrazyMind90",
            kind: .dialerTheme,
            description: "Theme bàn phím số gọi điện đen tuyền tiết kiệm pin tối đa cho màn hình OLED Super Retina.",
            version: "1.4",
            iconSystemName: "circle.grid.3x3.circle.fill",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: false,
            targetApp: "MobilePhone"
        ),
        ThreeOnePackage(
            id: "poster.cyber.lemon",
            name: "Cyber Lemon Dynamics",
            author: "YangJiii",
            kind: .wallpaper,
            description: "Gói hình nền PosterBoard động định dạng .tendies với hiệu ứng hạt vàng lấp lánh khi mở khóa màn hình.",
            version: "3.0",
            iconSystemName: "sparkles.rectangle.stack.fill",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: false,
            targetApp: "PosterBoard"
        ),
        ThreeOnePackage(
            id: "cleaner.fast.cache",
            name: "Smart Fast Cleaner",
            author: "YangJiii",
            kind: .tool,
            description: "Công cụ dọn dẹp cache rác của Safari, OTA residuals và log hệ thống an toàn.",
            version: "2.0",
            iconSystemName: "trash.circle.fill",
            accentColor: Color(hex: "FFD60A"),
            isInstalled: true,
            targetApp: "System"
        )
    ]
    
    func toggleInstall(package: ThreeOnePackage) {
        if let index = packages.firstIndex(where: { $0.id == package.id }) {
            packages[index].isInstalled.toggle()
            HapticManager.shared.impact(.medium)
        }
    }
}
