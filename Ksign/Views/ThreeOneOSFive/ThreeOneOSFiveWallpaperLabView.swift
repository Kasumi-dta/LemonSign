//
//  ThreeOneOSFiveWallpaperLabView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct WallpaperPackageItem: Identifiable {
    let id = UUID()
    let name: String
    let author: String
    let type: String
    let icon: String
    let description: String
    var isApplied: Bool
}

struct ThreeOneOSFiveWallpaperLabView: View {
    @State private var wallpapers: [WallpaperPackageItem] = [
        WallpaperPackageItem(
            name: "Cyber Lemon Dynamics",
            author: "YangJiii",
            type: ".tendies",
            icon: "sparkles.rectangle.stack.fill",
            description: "Gói hình nền PosterBoard động với hiệu ứng hạt vàng lấp lánh khi mở khóa.",
            isApplied: true
        ),
        WallpaperPackageItem(
            name: "Deep Space OLED",
            author: "duongduong0908",
            type: ".tendies",
            icon: "moon.stars.fill",
            description: "Bộ hình nền vũ trụ đen sâu hỗ trợ Always-On Display trên iOS 17 & 18.",
            isApplied: false
        ),
        WallpaperPackageItem(
            name: "Neon Glow Dialer",
            author: "duongduong0908",
            type: ".3105pass",
            icon: "phone.bubble.fill",
            description: "Bàn phím số gọi điện phát sáng dạ quang màu vàng chanh hiện đại.",
            isApplied: true
        ),
        WallpaperPackageItem(
            name: "Minimal OLED Dialer",
            author: "CrazyMind90",
            type: ".3105pass",
            icon: "circle.grid.3x3.circle.fill",
            description: "Giao diện bàn phím gọi điện đen tuyền tối giản tiết kiệm năng lượng.",
            isApplied: false
        )
    ]
    
    @State private var isImporting = false
    @State private var showResetAlert = false
    @State private var toastMessage = ""
    @State private var showToast = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Info
                HStack(spacing: 14) {
                    Image(systemName: "photo.artframe")
                        .font(.title)
                        .foregroundColor(Color(hex: "FFD60A"))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("PosterBoard & Dialer Lab")
                            .font(.headline.weight(.bold))
                        Text("Quản lý gói hình nền PosterBoard (.tendies) và theme bàn phím gọi điện (.3105pass)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Content List
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Gói giao diện đã cài")
                            .font(.headline.weight(.bold))
                        Spacer()
                        Text("\(wallpapers.count) Gói")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach($wallpapers) { $item in
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: "FFD60A").opacity(0.18))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: item.icon)
                                        .font(.title3)
                                        .foregroundColor(Color(hex: "DDA200"))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(item.name)
                                            .font(.body.weight(.semibold))
                                        
                                        Text(item.type)
                                            .font(.caption2.weight(.bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(hex: "FFD60A").opacity(0.25))
                                            .foregroundColor(Color(hex: "8B6914"))
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text("Bởi: \(item.author) • \(item.description)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Button {
                                    item.isApplied.toggle()
                                    HapticManager.shared.impact(.medium)
                                    displayToast(item.isApplied ? "Đã áp dụng \(item.name)" : "Đã hủy áp dụng \(item.name)")
                                } label: {
                                    Text(item.isApplied ? "Đang bật" : "Áp dụng")
                                        .font(.caption.weight(.bold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(item.isApplied ? Color(hex: "FFD60A") : Color(uiColor: .tertiarySystemFill))
                                        .foregroundColor(item.isApplied ? .black : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding()
                            
                            if item.id != wallpapers.last?.id {
                                Divider().padding(.leading, 70)
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        isImporting = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Nhập gói .tendies / .3105pass")
                        }
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "FFD60A"))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    
                    Button {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Đặt lại hình nền & bàn phím gốc")
                        }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .padding(.vertical)
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    let filename = url.lastPathComponent
                    let ext = url.pathExtension.lowercased()
                    let isDialer = ext.contains("pass")
                    let newItem = WallpaperPackageItem(
                        name: filename,
                        author: "Tệp ngoài",
                        type: isDialer ? ".3105pass" : ".tendies",
                        icon: isDialer ? "phone.bubble.fill" : "photo.stack.fill",
                        description: "Gói giao diện nhập từ bộ nhớ máy",
                        isApplied: true
                    )
                    wallpapers.insert(newItem, at: 0)
                    displayToast("Đã nhập thành công: \(filename)")
                    HapticManager.shared.notification(.success)
                }
            case .failure(let err):
                displayToast("Lỗi nhập tệp: \(err.localizedDescription)")
            }
        }
        .alert("Đặt lại PosterBoard", isPresented: $showResetAlert) {
            Button("Đặt lại", role: .destructive) {
                for i in 0..<wallpapers.count { wallpapers[i].isApplied = false }
                displayToast("Đã đặt lại PosterBoard & Dialer về nguyên bản!")
                HapticManager.shared.notification(.success)
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Thao tác này sẽ xóa mọi hình nền và theme bàn phím gọi điện đang áp dụng và đưa PosterBoard về cấu hình gốc.")
        }
        .overlay(alignment: .bottom) {
            if showToast {
                Text(toastMessage)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private func displayToast(_ msg: String) {
        toastMessage = msg
        withAnimation(.spring()) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut) {
                showToast = false
            }
        }
    }
}
