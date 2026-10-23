//
//  AntiRevokeView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct AntiRevokeView: View {
    @AppStorage("lemonsign.antiRevokeEnabled") private var antiRevokeEnabled: Bool = true
    @State private var showingCopiedAlert = false
    
    private let blockedHosts = [
        "ocsp.apple.com",
        "ocsp2.apple.com",
        "ppq.apple.com",
        "world-gen.g.aaplimg.com",
        "gdmf.apple.com"
    ]
    
    // Encoded Mobileconfig profile that blocks Apple OCSP/PPQ via encrypted DoH/DoT
    private let mobileconfigURL = "https://raw.githubusercontent.com/Kasumi-dta/LemonSign/refs/heads/main/assets/anti-revoke.mobileconfig"
    
    var body: some View {
        NBList("Lá chắn Chống Thu hồi") {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "FFD60A"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bảo vệ Chứng chỉ Sideload")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Chặn máy chủ Apple OCSP kiểm tra và thu hồi chứng chỉ P12 / Enterprise.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Label("Trạng thái lá chắn", systemImage: "checkmark.seal.fill")
                            .font(.subheadline)
                        Spacer()
                        Text("Sẵn sàng bảo vệ")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 4)
            }
            
            NBSection("Cài đặt Hồ sơ DNS Bảo vệ") {
                Button {
                    _installProfile()
                } label: {
                    HStack {
                        Label("Cài đặt Hồ sơ DNS Anti-Revoke", systemImage: "arrow.down.doc.fill")
                            .foregroundColor(Color(hex: "FFD60A"))
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "safari")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button {
                    _copyHosts()
                } label: {
                    Label("Sao chép danh sách chặn Hosts", systemImage: "doc.on.doc")
                }
            } footer: {
                Text("Nhấn 'Cài đặt Hồ sơ' để tải profile DNS mã hóa. Sau khi tải, hãy vào Cài đặt iOS > Đã tải về hồ sơ > Cài đặt.")
            }
            
            NBSection("Hướng dẫn kích hoạt trên iOS") {
                VStack(alignment: .leading, spacing: 10) {
                    _stepRow(number: "1", text: "Nhấn nút 'Cài đặt Hồ sơ DNS' ở trên để mở liên kết tải về qua Safari.")
                    _stepRow(number: "2", text: "Khi Safari hiển thị hộp thoại, chọn 'Cho phép' để tải hồ sơ cấu hình.")
                    _stepRow(number: "3", text: "Vào Cài đặt của iPhone/iPad > chọn 'Đã tải về hồ sơ' (ngay dưới tên Apple ID).")
                    _stepRow(number: "4", text: "Nhấn 'Cài đặt' ở góc trên bên phải và nhập mật mã mở máy của bạn.")
                    _stepRow(number: "5", text: "Vào Cài đặt > Cài đặt chung > VPN & Quản lý thiết bị > DNS > Chọn cấu hình Lemon Anti-Revoke.")
                }
                .padding(.vertical, 4)
            }
            
            NBSection("Máy chủ bị chặn (Apple Revocation Servers)") {
                ForEach(blockedHosts, id: \.self) { host in
                    HStack {
                        Image(systemName: "nosign")
                            .foregroundColor(.red)
                            .font(.footnote)
                        Text(host)
                            .font(.system(.footnote, design: .monospaced))
                        Spacer()
                        Text("Đã chặn")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("Khi các tên miền trên bị chặn, iOS không thể liên lạc với máy chủ thu hồi của Apple, giúp ứng dụng đã ký tồn tại lâu dài.")
            }
        }
        .alert("Đã sao chép", isPresented: $showingCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Đã sao chép danh sách tên miền chặn OCSP vào bộ nhớ tạm.")
        }
    }
    
    @ViewBuilder
    private func _stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 20, height: 20)
                .background(Color(hex: "FFD60A"))
                .clipShape(Circle())
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func _installProfile() {
        if let url = URL(string: mobileconfigURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func _copyHosts() {
        UIPasteboard.general.string = blockedHosts.joined(separator: "\n")
        showingCopiedAlert = true
    }
}
