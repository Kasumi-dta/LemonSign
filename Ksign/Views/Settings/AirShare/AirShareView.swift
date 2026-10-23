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
    @State private var isServerRunning = true
    @State private var localIP: String = "127.0.0.1"
    @State private var sharePort: Int = 8088
    @State private var copiedAlert = false
    
    private var shareURLString: String {
        "http://\(localIP):\(sharePort)"
    }
    
    var body: some View {
        NBList("AirShare WiFi & QR") {
            Section {
                VStack(spacing: 16) {
                    if let qrImage = _generateQRCode(from: shareURLString) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    }
                    
                    VStack(spacing: 6) {
                        Text(shareURLString)
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "FFD60A"))
                        
                        Text("Quét mã QR bằng Camera của thiết bị khác cùng mạng WiFi để tải và nhận file IPA trực tiếp không cần dây cáp.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            
            NBSection("Thao tác Nhanh") {
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
                    Label("Địa chỉ IP nội bộ", systemImage: "network")
                    Spacer()
                    Text(localIP)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Cổng kết nối (Port)", systemImage: "number")
                    Spacer()
                    Text("\(sharePort)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Trạng thái phát sóng", systemImage: "antenna.radiowaves.left.and.right")
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Đang mở chia sẻ")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            } footer: {
                Text("Cả hai thiết bị cần kết nối vào cùng một mạng Wi-Fi. AirShare bảo vệ đường truyền nội bộ LAN tốc độ cao.")
            }
        }
        .onAppear {
            _refreshNetworkInfo()
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
