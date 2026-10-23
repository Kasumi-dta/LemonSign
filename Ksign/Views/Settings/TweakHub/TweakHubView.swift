//
//  TweakHubView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct PresetTweak: Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
    let category: String
    let description: String
    let icon: String
    let version: String
}

struct TweakHubView: View {
    @AppStorage("lemonsign.autoInjectAdblock") private var autoInjectAdblock = false
    @AppStorage("lemonsign.autoInjectBypassJB") private var autoInjectBypassJB = false
    @AppStorage("lemonsign.autoInjectFPSUnlocker") private var autoInjectFPSUnlocker = false
    @AppStorage("lemonsign.autoInjectKeepAlive") private var autoInjectKeepAlive = false
    
    @State private var showingInfoAlert = false
    @State private var selectedTweakInfo: PresetTweak?
    
    let presets: [PresetTweak] = [
        PresetTweak(
            name: "Adblock Pro Universal",
            fileName: "AdblockPro.dylib",
            category: "Đa phương tiện",
            description: "Chặn toàn bộ quảng cáo video, banner và pop-up trên YouTube, TikTok, Facebook và các app xem phim.",
            icon: "hand.raised.fill",
            version: "v2.4.1"
        ),
        PresetTweak(
            name: "Bypass JB & Sideload Detection",
            fileName: "BypassJBDetection.dylib",
            category: "Bảo mật & Hệ thống",
            description: "Ẩn môi trường Sideload và kiểm tra Jailbreak đối với ứng dụng ngân hàng, ví điện tử và game chống hack.",
            icon: "lock.shield.fill",
            version: "v1.8.0"
        ),
        PresetTweak(
            name: "ProMotion 120 FPS Unlocker",
            fileName: "FPSUnlocker.dylib",
            category: "Hiệu năng",
            description: "Mở khóa giới hạn tần số quét màn hình lên tới 120Hz ProMotion trên các dòng iPhone Pro / iPad Pro.",
            icon: "speedometer",
            version: "v1.2.0"
        ),
        PresetTweak(
            name: "Extended Background Runner",
            fileName: "KeepAppAlive.dylib",
            category: "Tiện ích ngầm",
            description: "Duy trì quyền chạy ngầm không bị hệ thống iOS đóng (hữu ích cho app tải file, nghe nhạc tắt màn hình).",
            icon: "bolt.fill",
            version: "v3.0.2"
        ),
        PresetTweak(
            name: "Document File Picker Fixer",
            fileName: "DocumentPicker.dylib",
            category: "Tiện ích tệp",
            description: "Kích hoạt hộp thoại chọn tệp hệ thống cho các app nhập/xuất dữ liệu bị khóa sandbox.",
            icon: "folder.badge.gearshape",
            version: "v1.1.0"
        )
    ]
    
    var body: some View {
        NBList("Kho Tweak & Dylib") {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "puzzlepiece.extension.fill")
                            .font(.system(size: 34))
                            .foregroundColor(Color(hex: "FFD60A"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Thư viện Tweak Tích Hợp")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Tự động tiêm (inject) các mã mở rộng phổ biến vào file IPA khi ký.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            NBSection("Tự động tiêm khi Ký IPA") {
                Toggle(isOn: $autoInjectAdblock) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Chặn quảng cáo (Adblock Pro)")
                            Text("Tự động tiêm Adblock vào app đa phương tiện")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Toggle(isOn: $autoInjectBypassJB) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Bypass phát hiện Sideload / JB")
                            Text("Ẩn chữ ký không chính chủ cho app ngân hàng, game")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Toggle(isOn: $autoInjectFPSUnlocker) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Mở khóa 120 FPS ProMotion")
                            Text("Ép tần số quét tối đa trên màn hình 120Hz")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "speedometer")
                            .foregroundColor(Color(hex: "FFD60A"))
                    }
                }
                
                Toggle(isOn: $autoInjectKeepAlive) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Duy trì chạy ngầm (Keep-Alive)")
                            Text("Giữ ứng dụng tiếp tục chạy ngầm khi khóa máy")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.blue)
                    }
                }
            } footer: {
                Text("Khi bật, LemonSign sẽ tự động ghép các dylib tương ứng vào file IPA trong quá trình ký bằng công cụ optool.")
            }
            
            NBSection("Danh sách Tweak có sẵn trong Thư viện") {
                ForEach(presets) { tweak in
                    Button {
                        selectedTweakInfo = tweak
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: tweak.icon)
                                .foregroundColor(Color(hex: "FFD60A"))
                                .font(.title3)
                                .frame(width: 28)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(tweak.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(tweak.version)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Text(tweak.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
            } footer: {
                Text("Bạn cũng có thể thêm file .dylib hoặc .deb tùy chỉnh từ máy bằng cách vào tab Tệp hoặc trong mục Tùy chỉnh nâng cao khi ký.")
            }
        }
        .sheet(item: $selectedTweakInfo) { tweak in
            NBNavigationView(tweak.name, displayMode: .inline) {
                Form {
                    Section("Thông tin Tweak") {
                        LabeledContent("Tên tệp", value: tweak.fileName)
                        LabeledContent("Phiên bản", value: tweak.version)
                        LabeledContent("Phân loại", value: tweak.category)
                    }
                    
                    Section("Mô tả chi tiết") {
                        Text(tweak.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Section("Cách sử dụng") {
                        Text("Khi ký một ứng dụng bất kỳ trong Thư viện, chọn mục 'Nâng cao' > 'Tweaks' > 'Thêm dylib' và tick chọn \(tweak.name) để gắn kèm vào IPA.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .toolbar {
                    NBToolbarButton(role: .dismiss)
                }
            }
            .presentationDetents([.medium])
        }
    }
}
