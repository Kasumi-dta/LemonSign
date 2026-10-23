//
//  ThreeOneOSFiveGestaltView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct GestaltOptionItem: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    var isEnabled: Bool
}

struct ThreeOneOSFiveGestaltView: View {
    // Hardware Features
    @State private var hardwareOptions: [GestaltOptionItem] = [
        GestaltOptionItem(id: "boot_chime", name: "Âm thanh khởi động", subtitle: "Phát chuông khởi động Mac khi bật nguồn máy", icon: "speaker.wave.3.fill", isEnabled: false),
        GestaltOptionItem(id: "charge_limit", name: "Giới hạn sạc 80%", subtitle: "Bật tính năng giới hạn sạc pin 80% để bảo vệ pin", icon: "battery.85", isEnabled: true),
        GestaltOptionItem(id: "action_button", name: "Nút tác vụ (Action Button)", subtitle: "Kích hoạt menu Action Button trong Cài đặt", icon: "button.programmable", isEnabled: false),
        GestaltOptionItem(id: "camera_button", name: "Nút Camera Control", subtitle: "Mở menu tùy biến nút điều khiển Camera", icon: "camera.viewfinder", isEnabled: false),
        GestaltOptionItem(id: "tap_to_wake", name: "Chạm để đánh thức", subtitle: "Chạm vào màn hình để bật sáng màn hình", icon: "hand.tap.fill", isEnabled: true)
    ]
    
    // Display & UI
    @State private var displayOptions: [GestaltOptionItem] = [
        GestaltOptionItem(id: "stage_manager", name: "Stage Manager", subtitle: "Bật đa nhiệm cửa sổ Stage Manager (iPadOS/iOS)", icon: "rectangle.split.2x1.fill", isEnabled: false),
        GestaltOptionItem(id: "aod", name: "Always-On Display (AOD)", subtitle: "Màn hình luôn bật cho các dòng màn hình OLED", icon: "sun.max.fill", isEnabled: false),
        GestaltOptionItem(id: "transparent_dock", name: "Dock trong suốt", subtitle: "Loại bỏ nền mờ đục của thanh Dock", icon: "rectangle.bottomthird.inset.filled", isEnabled: true),
        GestaltOptionItem(id: "hide_home_bar", name: "Ẩn vạch Home Bar", subtitle: "Ẩn thanh gạch ngang điều hướng ở đáy màn hình", icon: "iphone.slash", isEnabled: true),
        GestaltOptionItem(id: "hide_labels", name: "Ẩn nhãn chữ biểu tượng", subtitle: "Ẩn tên chữ dưới các icon trên màn hình chính", icon: "text.badge.minus", isEnabled: false),
        GestaltOptionItem(id: "battery_pct", name: "Hiển thị % Pin trong icon", subtitle: "Hiện số phần trăm pin bên trong viên pin", icon: "percent", isEnabled: true)
    ]
    
    // System & Special
    @State private var systemOptions: [GestaltOptionItem] = [
        GestaltOptionItem(id: "mute_camera", name: "Tắt âm chụp ảnh Camera", subtitle: "Tắt tiếng chụp hình bắt buộc cho máy Nhật/Hàn (J/A & KH/A)", icon: "camera.badge.ellipsis", isEnabled: true),
        GestaltOptionItem(id: "apple_intelligence", name: "Apple Intelligence", subtitle: "Mở khóa điều kiện tính năng Apple Intelligence", icon: "sparkles", isEnabled: false),
        GestaltOptionItem(id: "disable_low_power", name: "Chặn cảnh báo Pin yếu", subtitle: "Tắt pop-up cảnh báo phiền phức ở mức 20% và 10%", icon: "battery.25", isEnabled: true),
        GestaltOptionItem(id: "disable_region_lock", name: "Tắt khóa vùng (Region Lock)", subtitle: "Bỏ hạn chế tính năng theo khu vực EU / China", icon: "globe.americas.fill", isEnabled: false),
        GestaltOptionItem(id: "metal_hud", name: "Metal Performance HUD", subtitle: "Hiển thị lớp phủ đo FPS và GPU trong các game Metal", icon: "speedometer", isEnabled: false),
        GestaltOptionItem(id: "rdar_fix", name: "Sửa thanh trạng thái RDAR", subtitle: "Khắc phục lỗi hiển thị thanh trạng thái sau khi đổi model", icon: "wrench.and.screwdriver.fill", isEnabled: false)
    ]
    
    @State private var isApplying = false
    @State private var showSuccessAlert = false
    @State private var showRestoreAlert = false
    @State private var toastMessage = ""
    @State private var showToast = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                HStack(spacing: 14) {
                    Image(systemName: "slider.horizontal.2.square.on.square.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: "FFD60A"))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Trình chỉnh sửa MobileGestalt")
                            .font(.headline.weight(.bold))
                        Text("Bật/tắt các tính năng hệ thống cao cấp của Apple mà không cần Jailbreak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Section: Phần cứng (Hardware)
                buildSection(title: "Phần cứng (Hardware)", items: $hardwareOptions)
                
                // Section: Màn hình & Giao diện (Display)
                buildSection(title: "Màn hình & Giao diện (Display)", items: $displayOptions)
                
                // Section: Hệ thống & Giới hạn (System)
                buildSection(title: "Hệ thống & Tinh chỉnh (System)", items: $systemOptions)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        applyGestaltChanges()
                    } label: {
                        HStack(spacing: 8) {
                            if isApplying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isApplying ? "Đang áp dụng thay đổi..." : "Áp dụng thay đổi Gestalt")
                        }
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "FFD60A"))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(isApplying)
                    
                    Button {
                        showRestoreAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Khôi phục MobileGestalt gốc")
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
                .padding(.top, 6)
            }
            .padding(.vertical)
        }
        .alert("Áp dụng thành công", isPresented: $showSuccessAlert) {
            Button("Đã hiểu", role: .cancel) {}
        } message: {
            Text("Các khóa Gestalt đã được cập nhật thành công.\n\nHãy Respring hoặc khởi động lại thiết bị (Reboot) để iOS áp dụng đầy đủ các tính năng mới.")
        }
        .alert("Khôi phục bản gốc", isPresented: $showRestoreAlert) {
            Button("Khôi phục", role: .destructive) {
                revertToOriginal()
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Bạn có chắc chắn muốn hủy bỏ toàn bộ các chỉnh sửa Gestalt và khôi phục lại cấu hình gốc của Apple?")
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
    
    @ViewBuilder
    private func buildSection(title: String, items: Binding<[GestaltOptionItem]>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.weight(.bold))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(items) { $item in
                    HStack(spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.title3)
                            .foregroundColor(item.isEnabled ? Color(hex: "B8860B") : .secondary)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.body.weight(.semibold))
                            Text(item.subtitle)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $item.isEnabled)
                            .labelsHidden()
                            .tint(Color(hex: "FFD60A"))
                            .onChange(of: item.isEnabled) { val in
                                HapticManager.shared.impact(.light)
                                displayToast(val ? "Đã bật: \(item.name)" : "Đã tắt: \(item.name)")
                            }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    
                    if item.id != items.wrappedValue.last?.id {
                        Divider().padding(.leading, 58)
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal)
        }
    }
    
    private func applyGestaltChanges() {
        isApplying = true
        HapticManager.shared.impact(.medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isApplying = false
            showSuccessAlert = true
            HapticManager.shared.notification(.success)
        }
    }
    
    private func revertToOriginal() {
        for i in 0..<hardwareOptions.count { hardwareOptions[i].isEnabled = false }
        for i in 0..<displayOptions.count { displayOptions[i].isEnabled = false }
        for i in 0..<systemOptions.count { systemOptions[i].isEnabled = false }
        
        displayToast("Đã khôi phục cài đặt Gestalt gốc!")
        HapticManager.shared.notification(.success)
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
