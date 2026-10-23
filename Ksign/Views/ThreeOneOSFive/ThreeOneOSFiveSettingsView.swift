//
//  ThreeOneOSFiveSettingsView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct ThreeOneOSFiveSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Feature Options
    @AppStorage("3105.cleanerEnabled") private var cleanerEnabled = true
    @AppStorage("3105.developerMode") private var developerMode = false
    @AppStorage("3105.autoBackup") private var autoBackup = true
    @AppStorage("3105.detailedLogs") private var detailedLogs = true
    
    @State private var showCredits = false
    @State private var showResetWallpaperAlert = false
    @State private var toastMessage = ""
    @State private var showToast = false
    
    private var isSupported: Bool {
        ThreeOneOSFiveSupport.isSupported
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section: App Identity
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(hex: "FFD60A"))
                                .frame(width: 52, height: 52)
                            
                            Image(systemName: "puzzlepiece.extension.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("3105")
                                    .font(.title3.weight(.bold))
                                Text("v2.0")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "FFD60A").opacity(0.2))
                                    .foregroundColor(Color(hex: "8B6914"))
                                    .clipShape(Capsule())
                            }
                            
                            Text("Tác giả: YangJiii • GPL-3.0")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Section: Feature Toggles
                Section("Tùy chọn tính năng") {
                    Toggle(isOn: $cleanerEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tính năng Dọn dẹp")
                                    .font(.body)
                                Text("Hiển thị tab dọn rác và quét cache ứng dụng")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(hex: "B8860B"))
                        }
                    }
                    .tint(Color(hex: "FFD60A"))
                    
                    Toggle(isOn: $developerMode) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chế độ nhà phát triển")
                                    .font(.body)
                                Text("Mở khóa trình chỉnh sửa plist, xuất dự án và log nâng cao")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(Color(hex: "B8860B"))
                        }
                    }
                    .tint(Color(hex: "FFD60A"))
                    
                    Toggle(isOn: $autoBackup) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tự động sao lưu trước khi Patch")
                                    .font(.body)
                                Text("Tạo bản snapshot dữ liệu gốc trước khi ghi đè tệp")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(Color(hex: "B8860B"))
                        }
                    }
                    .tint(Color(hex: "FFD60A"))
                }
                
                // Section: PosterBoard Reset
                Section("Tùy chọn PosterBoard & Hình nền") {
                    Button {
                        showResetWallpaperAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("Đặt lại hình nền PosterBoard về mặc định")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Section: Device & Environment
                Section("Thông tin thiết bị & Tương thích") {
                    HStack {
                        Text("Model thiết bị")
                        Spacer()
                        Text(UIDevice.current.model)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Phiên bản iOS")
                        Spacer()
                        Text("iOS \(ThreeOneOSFiveSupport.versionString)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Trạng thái hỗ trợ")
                        Spacer()
                        Text(isSupported ? "Được hỗ trợ" : "Chưa tương thích")
                            .font(.body.weight(.semibold))
                            .foregroundColor(isSupported ? .green : .red)
                    }
                }
                
                // Section: Verified iOS Ranges
                Section("Phạm vi iOS đã xác minh của 3105") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• iOS 17: 17.0 đến 17.7.x")
                        Text("• iOS 18: 18.0 đến 18.7.1")
                        Text("• iOS 26: 26.0 đến 26.6.1")
                        Text("• iOS 27: Developer Beta 1–4 & Public Beta 1–2")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 2)
                }
                
                // Section: Author & Copyright
                Section("Bản quyền & Ghi công") {
                    Button {
                        showCredits = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                            Text("Xem thông tin bản quyền & Tác giả YangJiii")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Tùy chọn 3105")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xong") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "DDA200"))
                }
            }
            .sheet(isPresented: $showCredits) {
                ThreeOneOSFiveCreditsView()
            }
            .alert("Đặt lại PosterBoard", isPresented: $showResetWallpaperAlert) {
                Button("Đặt lại", role: .destructive) {
                    HapticManager.shared.notification(.success)
                    displayToast("Đã đặt lại PosterBoard về cấu hình gốc!")
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Toàn bộ hình nền tùy biến sẽ được đưa về mặc định của hệ điều hành.")
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
