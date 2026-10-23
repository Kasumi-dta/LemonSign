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
    let version: String
    let target: String
    var isEnabled: Bool
}

struct ThreeOneOSFiveProjectsView: View {
    @State private var patches: [ActivePatchItem] = [
        ActivePatchItem(name: "Dock Blur Transparency", version: "1.2", target: "com.apple.springboard", isEnabled: true),
        ActivePatchItem(name: "Supervised Flag Enabler", version: "2.1", target: "com.apple.Preferences", isEnabled: true),
        ActivePatchItem(name: "Disable Low Power Alert", version: "1.0", target: "com.apple.springboard", isEnabled: false)
    ]
    
    @State private var isImporting = false
    @State private var showRestoreAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Info Card
                HStack(spacing: 14) {
                    Image(systemName: "puzzlepiece.extension.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: "FFD60A"))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Quản lý Bản vá (.3105)")
                            .font(.headline.weight(.bold))
                        Text("Kích hoạt hoặc gỡ bỏ các patch tùy biến hệ thống đã cài đặt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Patches List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Bản vá đang hoạt động")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach($patches) { $patch in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(patch.name)
                                        .font(.body.weight(.semibold))
                                    Text("Mục tiêu: \(patch.target) (v\(patch.version))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $patch.isEnabled)
                                    .labelsHidden()
                                    .tint(Color(hex: "FFD60A"))
                                    .onChange(of: patch.isEnabled) { _ in
                                        HapticManager.shared.impact(.light)
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
                
                // Actions
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
        .alert("Khôi phục dữ liệu gốc", isPresented: $showRestoreAlert) {
            Button("Khôi phục", role: .destructive) {
                for i in 0..<patches.count {
                    patches[i].isEnabled = false
                }
                HapticManager.shared.notification(.success)
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Thao tác này sẽ hủy áp dụng toàn bộ các bản vá 3105 và đưa các tệp hệ thống về trạng thái ban đầu.")
        }
    }
}
