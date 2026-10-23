//
//  ThreeOneOSFiveView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

enum ThreeOneSubTab: String, CaseIterable, Identifiable {
    case store = "Cửa hàng"
    case appData = "App Data"
    case cleaner = "Dọn dẹp"
    case projects = "Bản vá"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .store: return "bag.fill"
        case .appData: return "externaldrive.fill"
        case .cleaner: return "trash.fill"
        case .projects: return "puzzlepiece.extension.fill"
        }
    }
}

struct ThreeOneOSFiveView: View {
    @State private var selectedSubTab: ThreeOneSubTab = .store
    @State private var isPreviewBypassed = false
    @State private var showDownloadToast = false
    
    private var isSupported: Bool {
        ThreeOneOSFiveSupport.isSupported
    }
    
    var body: some View {
        NBNavigationView("3105") {
            ZStack {
                // Main Content View
                VStack(spacing: 0) {
                    // Sub Tab Picker
                    Picker("Chuyên mục", selection: $selectedSubTab) {
                        ForEach(ThreeOneSubTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    
                    // Selected Subview
                    Group {
                        switch selectedSubTab {
                        case .store:
                            ThreeOneOSFiveMarketplaceView()
                        case .appData:
                            ThreeOneOSFiveAppDataView()
                        case .cleaner:
                            ThreeOneOSFiveCleanerView()
                        case .projects:
                            ThreeOneOSFiveProjectsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .blur(radius: (!isSupported && !isPreviewBypassed) ? 14 : 0)
                .opacity((!isSupported && !isPreviewBypassed) ? 0.35 : 1.0)
                .disabled(!isSupported && !isPreviewBypassed)
                
                // Dimmed Overlay for Unsupported Devices
                if !isSupported && !isPreviewBypassed {
                    unsupportedOverlay
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isSupported ? Color.green : Color(hex: "FFD60A"))
                            .frame(width: 8, height: 8)
                        
                        Text(isSupported ? "iOS \(ThreeOneOSFiveSupport.versionString)" : "Chưa hỗ trợ")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(isSupported ? .green : Color(hex: "DDA200"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private var unsupportedOverlay: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color(hex: "FFD60A").opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color(hex: "FFD60A"))
            }
            
            VStack(spacing: 8) {
                Text("Thiết bị chưa hỗ trợ 3105")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text("Thiết bị của bạn đang chạy **iOS \(ThreeOneOSFiveSupport.versionString)**.\nCác tính năng can thiệp sâu của 3105 yêu cầu:\n- iOS 17: 17.0 đến 17.7\n- iOS 18: 18.0 đến 18.7.1")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text("🛡️ Mọi tính năng Ký IPA, Cài đặt ứng dụng và Thư viện của LemonSign vẫn hoạt động bình thường.")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(Color(hex: "DDA200"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }
            
            VStack(spacing: 10) {
                Button {
                    withAnimation(.spring()) {
                        isPreviewBypassed = true
                    }
                    HapticManager.shared.impact(.light)
                } label: {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("Xem trước giao diện 3105")
                    }
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "FFD60A"))
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                Button {
                    if let url = URL(string: "https://github.com/YangJiiii/3105/releases/download/v2.0/3105-2.0-build8-20260914-125906-unsigned.ipa") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        Text("Tải file IPA 3105 rời")
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)
        }
        .padding(26)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.18), radius: 24, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color(hex: "FFD60A").opacity(0.3), lineWidth: 1.5)
        )
        .padding()
    }
}
