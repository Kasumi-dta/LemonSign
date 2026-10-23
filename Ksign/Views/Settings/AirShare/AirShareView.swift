//
//  AirShareView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import NimbleViews

struct AirShareView: View {
    @ObservedObject private var server = AirShareServer.shared
    @State private var localIP: String = "127.0.0.1"
    @State private var copiedAlert = false
    
    private var shareURLString: String {
        "http://\(localIP):\(server.port)"
    }
    
    var body: some View {
        NBList("AirShare WiFi & QR") {
            Section {
                VStack(spacing: 16) {
                    if server.isRunning, let qrImage = _generateQRCode(from: shareURLString) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("Máy chủ đang tạm dừng")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 180, height: 180)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    
                    VStack(spacing: 6) {
                        Text(shareURLString)
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(server.isRunning ? Color(hex: "FFD60A") : .secondary)
                        
                        Text("Mở trình duyệt trên máy tính/thiết bị khác cùng mạng Wi-Fi hoặc quét mã QR để tải lên/xuống file IPA trực tiếp không cần dây cáp.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            
            NBSection("Bật / Tắt Dịch vụ") {
                Toggle(isOn: Binding(
                    get: { server.isRunning },
                    set: { enabled in
                        if enabled {
                            server.start()
                        } else {
                            server.stop()
                        }
                    }
                )) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phát sóng AirShare LAN")
                                .font(.headline)
                            Text(server.isRunning ? "Đang lắng nghe kết nối trên cổng \(server.port)" : "Đã tắt máy chủ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: server.isRunning ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                            .foregroundColor(server.isRunning ? Color(hex: "FFD60A") : .secondary)
                    }
                }
            }
            
            NBSection("Thao tác Nhanh") {
                Button {
                    _openInSafari()
                } label: {
                    HStack {
                        Label("Thử nghiệm trên Safari của máy", systemImage: "safari")
                            .foregroundColor(Color(hex: "FFD60A"))
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(!server.isRunning)
                
                Button {
                    UIPasteboard.general.string = shareURLString
                    copiedAlert = true
                } label: {
                    Label("Sao chép liên kết chia sẻ", systemImage: "doc.on.doc")
                }
                
                Button {
                    _shareURL()
                } label: {
                    Label("Chia sẻ qua AirDrop / Tin nhắn", systemImage: "square.and.arrow.up")
                }
            }
            
            NBSection("Trạng thái Máy chủ Nội bộ") {
                HStack {
                    Label("Địa chỉ IP nội bộ (LAN)", systemImage: "network")
                    Spacer()
                    Text(localIP)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Cổng kết nối (Port)", systemImage: "number")
                    Spacer()
                    Text("\(server.port)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Trạng thái phát sóng", systemImage: "circle.fill")
                        .foregroundColor(server.isRunning ? .green : .red)
                    Spacer()
                    Text(server.isRunning ? "Đang mở chia sẻ" : "Đã dừng")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(server.isRunning ? .green : .secondary)
                }
                
                HStack {
                    Label("Hoạt động gần nhất", systemImage: "clock.arrow.circlepath")
                    Spacer()
                    Text(server.lastAction)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if server.uploadCount > 0 {
                    HStack {
                        Label("Số tệp đã nhận qua WiFi", systemImage: "tray.and.arrow.down.fill")
                        Spacer()
                        Text("\(server.uploadCount)")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            } footer: {
                Text("Cả hai thiết bị cần kết nối vào cùng một mạng Wi-Fi. AirShare bảo vệ đường truyền nội bộ LAN tốc độ cao.")
            }
        }
        .onAppear {
            _refreshNetworkInfo()
            if !server.isRunning {
                server.start()
            }
        }
        .alert("Đã sao chép", isPresented: $copiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Đã sao chép địa chỉ AirShare vào bộ nhớ tạm: \(shareURLString)")
        }
    }
    
    private func _refreshNetworkInfo() {
        if let ip = ServerInstaller.getLocalAddress() {
            localIP = ip
        } else {
            localIP = "127.0.0.1"
        }
    }
    
    private func _openInSafari() {
        if let url = URL(string: "http://127.0.0.1:\(server.port)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func _generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    private func _shareURL() {
        if let url = URL(string: shareURLString) {
            UIActivityViewController.show(activityItems: [url])
        }
    }
}
