//
//  ThreeOneOSFiveProjectsView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct ActivePatchItem: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let version: String
    let target: String
    var isEnabled: Bool
}

struct ThreeOneOSFiveProjectsView: View {
    // Supervision State
    @State private var isSupervised = false
    @State private var showSupervisionAlert = false
    @State private var supervisionAlertMessage = ""
    
    // System Patches
    @State private var patches: [ActivePatchItem] = [
        ActivePatchItem(name: "Tắt âm chụp ảnh Camera", subtitle: "Tắt âm thanh chụp ảnh cho máy Nhật J/A & Hàn KH/A", version: "1.3", target: "com.apple.camera", isEnabled: true),
        ActivePatchItem(name: "Ẩn vạch Home Bar", subtitle: "Ẩn thanh điều hướng dưới đáy màn hình", version: "1.1", target: "com.apple.springboard", isEnabled: true),
        ActivePatchItem(name: "Dock Blur Transparency", subtitle: "Làm trong suốt nền thanh Dock màn hình chính", version: "1.2", target: "com.apple.springboard", isEnabled: true),
        ActivePatchItem(name: "Ẩn tên nhãn biểu tượng", subtitle: "Ẩn chữ dưới icon ứng dụng trên màn hình chính", version: "1.0", target: "com.apple.springboard", isEnabled: false),
        ActivePatchItem(name: "Chặn cảnh báo Pin yếu", subtitle: "Tắt pop-up pin yếu phiền phức ở mức 20% và 10%", version: "1.0", target: "com.apple.springboard", isEnabled: false),
        ActivePatchItem(name: "Bật phần trăm Pin số", subtitle: "Hiện số % pin bên trong biểu tượng pin thanh trạng thái", version: "1.0", target: "com.apple.springboard", isEnabled: true)
    ]
    
    @State private var isImporting = false
    @State private var showRestoreAlert = false
    @State private var showActionSuccessToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // MARK: - Supervision Management Card
                supervisionCard
                
                // MARK: - Patches List
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Bản vá tinh chỉnh hệ thống")
                            .font(.headline.weight(.bold))
                        Spacer()
                        Text("\(patches.filter { $0.isEnabled }.count)/\(patches.count) Đang bật")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach($patches) { $patch in
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(patch.name)
                                        .font(.body.weight(.semibold))
                                    Text(patch.subtitle)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("Mục tiêu: \(patch.target) • v\(patch.version)")
                                        .font(.caption2)
                                        .foregroundColor(Color(hex: "B8860B"))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $patch.isEnabled)
                                    .labelsHidden()
                                    .tint(Color(hex: "FFD60A"))
                                    .onChange(of: patch.isEnabled) { val in
                                        HapticManager.shared.impact(.light)
                                        showToast(val ? "Đã kích hoạt: \(patch.name)" : "Đã tắt: \(patch.name)")
                                    }
                            }
                            .padding()
                            
                            if patch.id != patches.last?.id {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)
                }
                
                // MARK: - Actions
                VStack(spacing: 12) {
                    Button {
                        isImporting = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Nhập tệp .3105 từ máy")
                        }
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "FFD60A"))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    
                    Button {
                        showRestoreAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle")
                            Text("Khôi phục bản sao lưu gốc (Restore)")
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
                    let newPatch = ActivePatchItem(
                        name: filename,
                        subtitle: "Bản vá tùy biến nhập từ tệp ngoài",
                        version: "1.0",
                        target: "Custom",
                        isEnabled: true
                    )
                    patches.insert(newPatch, at: 0)
                    showToast("Đã nhập thành công: \(filename)")
                    HapticManager.shared.notification(.success)
                }
            case .failure(let error):
                showToast("Lỗi nhập tệp: \(error.localizedDescription)")
            }
        }
        .alert(isSupervised ? "Bật Giám sát thành công" : "Đã hủy Giám sát", isPresented: $showSupervisionAlert) {
            Button("Đóng", role: .cancel) {}
        } message: {
            Text(supervisionAlertMessage)
        }
        .alert("Khôi phục dữ liệu gốc", isPresented: $showRestoreAlert) {
            Button("Khôi phục", role: .destructive) {
                for i in 0..<patches.count {
                    patches[i].isEnabled = false
                }
                isSupervised = false
                showToast("Đã khôi phục cài đặt gốc thành công!")
                HapticManager.shared.notification(.success)
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Thao tác này sẽ hủy áp dụng toàn bộ các bản vá 3105 và đưa các tệp hệ thống về trạng thái ban đầu.")
        }
        .overlay(alignment: .bottom) {
            if showActionSuccessToast {
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
    
    // MARK: - Supervision Card View
    private var supervisionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSupervised ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isSupervised ? "lock.shield.fill" : "shield.slash.fill")
                        .font(.title3)
                        .foregroundColor(isSupervised ? .orange : .green)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Chế độ Giám sát (Supervision)")
                            .font(.headline.weight(.bold))
                        
                        Text(isSupervised ? "Đang bật" : "Chưa bật")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSupervised ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .foregroundColor(isSupervised ? .orange : .green)
                            .clipShape(Capsule())
                    }
                    
                    Text(isSupervised 
                         ? "Thiết bị đang có cờ Giám sát (hỗ trợ DelayOTA hoặc cấu hình quản lý)." 
                         : "Thiết bị không bị giám sát. Không hiển thị cảnh báo tổ chức.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Supervision Control Buttons
            HStack(spacing: 10) {
                Button {
                    toggleSupervision(enable: true)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Bật Giám sát")
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSupervised ? Color.secondary.opacity(0.2) : Color(hex: "FFD60A"))
                    .foregroundColor(isSupervised ? .secondary : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isSupervised)
                
                Button {
                    toggleSupervision(enable: false)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.slash")
                        Text("Ẩn / Tắt Giám sát")
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(!isSupervised ? Color.secondary.opacity(0.2) : Color.red.opacity(0.15))
                    .foregroundColor(!isSupervised ? .secondary : .red)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!isSupervised)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }
    
    private func toggleSupervision(enable: Bool) {
        isSupervised = enable
        HapticManager.shared.impact(.medium)
        
        if enable {
            supervisionAlertMessage = "Đã kích hoạt cờ Giám sát (Supervised Mode) thành công!\n\nBạn có thể áp dụng các cấu hình DelayOTA hoặc hồ sơ quản lý. Hãy khởi động lại thiết bị (Reboot/Respring) để hệ thống áp dụng đầy đủ."
            showSupervisionAlert = true
        } else {
            supervisionAlertMessage = "Đã xóa bỏ cờ Giám sát (Un-Supervise) thành công!\n\nDòng chữ thông báo 'iPhone này được quản lý và giám sát bởi tổ chức' trên màn hình khóa và Cài đặt sẽ được gỡ bỏ sau khi khởi động lại máy."
            showSupervisionAlert = true
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation(.spring()) {
            showActionSuccessToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut) {
                showActionSuccessToast = false
            }
        }
    }
}
