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
    case gestalt = "Gestalt"
    case projects = "Bản vá"
    case wallpapers = "Hình nền & Phím"
    case appData = "App Data"
    case cleaner = "Dọn dẹp"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .store: return "bag.fill"
        case .gestalt: return "slider.horizontal.2.square.on.square.fill"
        case .projects: return "puzzlepiece.extension.fill"
        case .wallpapers: return "photo.artframe"
        case .appData: return "externaldrive.fill"
        case .cleaner: return "trash.fill"
        }
    }
}

struct ThreeOneOSFiveView: View {
    @State private var selectedSubTab: ThreeOneSubTab = .store
    @State private var isPreviewBypassed = false
    @State private var showSettings = false
    @State private var showCredits = false
    
    private var isSupported: Bool {
        ThreeOneOSFiveSupport.isSupported
    }
    
    var body: some View {
        NBNavigationView("3105") {
            ZStack {
                // Main Content View
                VStack(spacing: 0) {
                    // Sub Tab Chip Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ThreeOneSubTab.allCases) { tab in
                                Button {
                                    selectedSubTab = tab
                                    HapticManager.shared.impact(.light)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: tab.iconName)
                                        Text(tab.rawValue)
                                    }
                                    .font(.footnote.weight(.semibold))
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 7)
                                    .background(selectedSubTab == tab ? Color(hex: "FFD60A") : Color(uiColor: .secondarySystemGroupedBackground))
                                    .foregroundColor(selectedSubTab == tab ? .black : .primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(selectedSubTab == tab ? Color.clear : Color.primary.opacity(0.08), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    
                    // Author & Copyright Bar
                    HStack(spacing: 6) {
                        Image(systemName: "c.circle.fill")
                            .font(.caption2)
                            .foregroundColor(Color(hex: "B8860B"))
                        Text("3105 v2.0 • Bản quyền tác giả YangJiii (GPL-3.0)")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            showCredits = true
                            HapticManager.shared.impact(.light)
                        } label: {
                            Text("Xem bản quyền")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(Color(hex: "B8860B"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .systemGroupedBackground))
                    
                    Divider()
                    
                    // Selected Subview
                    Group {
                        switch selectedSubTab {
                        case .store:
                            ThreeOneOSFiveMarketplaceView()
                        case .gestalt:
                            ThreeOneOSFiveGestaltView()
                        case .projects:
                            ThreeOneOSFiveProjectsView()
                        case .wallpapers:
                            ThreeOneOSFiveWallpaperLabView()
                        case .appData:
                            ThreeOneOSFiveAppDataView()
                        case .cleaner:
                            ThreeOneOSFiveCleanerView()
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCredits = true
                        HapticManager.shared.impact(.light)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "c.circle.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                            Text("Bản quyền")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button {
                            showSettings = true
                            HapticManager.shared.impact(.light)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.caption.weight(.bold))
                                Text("Tùy chọn")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundColor(Color(hex: "8B6914"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "FFD60A").opacity(0.2))
                            .clipShape(Capsule())
                        }
                        
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
            .sheet(isPresented: $showSettings) {
                ThreeOneOSFiveSettingsView()
            }
            .sheet(isPresented: $showCredits) {
                ThreeOneOSFiveCreditsView()
            }
        }
    }
    
    private var unsupportedOverlay: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color(hex: "FFD60A").opacity(0.2))
                    .frame(width: 76, height: 76)
                
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 38))
                    .foregroundColor(Color(hex: "FFD60A"))
            }
            
            VStack(spacing: 6) {
                Text("Thiết bị chưa được hỗ trợ 3105")
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text("Phiên bản iOS hiện tại của bạn là **iOS \(ThreeOneOSFiveSupport.versionString)**.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(ThreeOneOSFiveSupport.compatibilityMessage)
                    .font(.caption)
                    .foregroundColor(Color(hex: "DDA200"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.top, 2)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Phạm vi iOS đã xác minh:")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(ThreeOneOSFiveSupport.supportedRangesDescription)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            Button {
                withAnimation(.spring()) {
                    isPreviewBypassed = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "eye.fill")
                    Text("Xem trước giao diện (Chỉ đọc)")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "FFD60A"))
                .clipShape(Capsule())
            }
            
            Text("Các tính năng Ký ứng dụng, Kho IPA và Chứng chỉ của LemonSign vẫn hoạt động 100% bình thường.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color(hex: "FFD60A").opacity(0.3), lineWidth: 1.5)
        )
        .padding(24)
    }
}
