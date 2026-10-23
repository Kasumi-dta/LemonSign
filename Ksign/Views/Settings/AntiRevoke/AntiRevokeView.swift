//
//  AntiRevokeView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import Network
import NimbleViews

// MARK: - Embedded Profile Data
struct AntiRevokeProfile {
    static let xmlString: String = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>PayloadContent</key>
    	<array>
    		<dict>
    			<key>DNSSettings</key>
    			<dict>
    				<key>DNSProtocol</key>
    				<string>HTTPS</string>
    				<key>ServerAddresses</key>
    				<array>
    					<string>0.0.0.0</string>
    					<string>127.0.0.1</string>
    				</array>
    				<key>ServerURL</key>
    				<string>https://anti-revoke.lemonsign.local/dns-query</string>
    				<key>SupplementalMatchDomains</key>
    				<array>
    					<string>ocsp.apple.com</string>
    					<string>ocsp2.apple.com</string>
    					<string>valid.apple.com</string>
    					<string>crl.apple.com</string>
    					<string>certs.apple.com</string>
    					<string>appattest.apple.com</string>
    					<string>vpp.itunes.apple.com</string>
    					<string>ppq.apple.com</string>
    					<string>world-gen.g.aaplimg.com</string>
    					<string>gdmf.apple.com</string>
    				</array>
    			</dict>
    			<key>PayloadDescription</key>
    			<string>Chặn máy chủ Apple OCSP và PPQ kiểm tra thu hồi chứng chỉ P12 / Doanh nghiệp</string>
    			<key>PayloadDisplayName</key>
    			<string>LemonSign Anti-Revoke DNS</string>
    			<key>PayloadIdentifier</key>
    			<string>com.lemonsign.dnsSettings.managed.antirevoke</string>
    			<key>PayloadType</key>
    			<string>com.apple.dnsSettings.managed</string>
    			<key>PayloadUUID</key>
    			<string>E6B9D214-3C8A-4217-BF10-5E6C7D8A9B01</string>
    			<key>PayloadVersion</key>
    			<integer>1</integer>
    			<key>ProhibitDisablement</key>
    			<false/>
    		</dict>
    	</array>
    	<key>PayloadDescription</key>
    	<string>Hồ sơ cấu hình bảo vệ chứng chỉ ứng dụng LemonSign, ngăn chặn Apple thu hồi chứng chỉ P12 / Enterprise.</string>
    	<key>PayloadDisplayName</key>
    	<string>LemonSign Anti-Revoke Profile</string>
    	<key>PayloadIdentifier</key>
    	<string>com.lemonsign.antirevoke.profile</string>
    	<key>PayloadOrganization</key>
    	<string>LemonSign</string>
    	<key>PayloadRemovalDisallowed</key>
    	<false/>
    	<key>PayloadScope</key>
    	<string>System</string>
    	<key>PayloadType</key>
    	<string>Configuration</string>
    	<key>PayloadUUID</key>
    	<string>8C7A3E21-7B14-4B2E-9D12-3D7E8F012345</string>
    	<key>PayloadVersion</key>
    	<integer>1</integer>
    </dict>
    </plist>
    """
    
    static var data: Data {
        Data(xmlString.utf8)
    }
}

// MARK: - Local Server for Safari MobileConfig Serving
final class AntiRevokeLocalServer {
    static let shared = AntiRevokeLocalServer()
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.lemonsign.antirevoke.server")
    
    func startAndServe(completion: @escaping (Int?) -> Void) {
        stop()
        
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            
            let newListener = try NWListener(using: params)
            self.listener = newListener
            
            newListener.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            
            newListener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if let port = newListener.port?.rawValue {
                        DispatchQueue.main.async {
                            completion(Int(port))
                        }
                    }
                case .failed(let err):
                    print("[AntiRevokeLocalServer] Listener failed: \(err)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                default:
                    break
                }
            }
            
            newListener.start(queue: queue)
        } catch {
            print("[AntiRevokeLocalServer] Could not initialize NWListener: \(error)")
            completion(nil)
        }
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 2048) { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            let body = AntiRevokeProfile.data
            let headers = [
                "HTTP/1.1 200 OK",
                "Content-Type: application/x-apple-aspen-config",
                "Content-Disposition: attachment; filename=\"LemonSign_AntiRevoke.mobileconfig\"",
                "Content-Length: \(body.count)",
                "Connection: close",
                "\r\n"
            ].joined(separator: "\r\n")
            
            var payload = Data(headers.utf8)
            payload.append(body)
            
            connection.send(content: payload, completion: .contentProcessed({ _ in
                connection.cancel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    self.stop()
                }
            }))
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
    }
}

// MARK: - View
struct AntiRevokeView: View {
    @AppStorage("lemonsign.antiRevokeEnabled") private var antiRevokeEnabled: Bool = true
    @State private var showingCopiedAlert = false
    @State private var isStartingServer = false
    
    private let blockedHosts = [
        "ocsp.apple.com",
        "ocsp2.apple.com",
        "ppq.apple.com",
        "world-gen.g.aaplimg.com",
        "gdmf.apple.com",
        "valid.apple.com",
        "crl.apple.com",
        "certs.apple.com",
        "appattest.apple.com",
        "vpp.itunes.apple.com"
    ]
    
    private let gitHubFallbackURL = "https://raw.githubusercontent.com/Kasumi-dta/LemonSign/refs/heads/main/assets/anti-revoke.mobileconfig"
    
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
                    _installProfileLocally()
                } label: {
                    HStack {
                        Label("Cài đặt Hồ sơ (Server Nội bộ - Khuyên dùng)", systemImage: "arrow.down.doc.fill")
                            .foregroundColor(Color(hex: "FFD60A"))
                            .fontWeight(.semibold)
                        Spacer()
                        if isStartingServer {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "safari")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .disabled(isStartingServer)
                
                Button {
                    _shareProfileFile()
                } label: {
                    HStack {
                        Label("Lưu vào Tệp / AirDrop (.mobileconfig)", systemImage: "square.and.arrow.down")
                        Spacer()
                        Image(systemName: "folder")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button {
                    _installFromGitHub()
                } label: {
                    HStack {
                        Label("Tải về từ GitHub (Dự phòng)", systemImage: "link")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
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
                Text("Nhấn 'Cài đặt Hồ sơ' để tải profile DNS mã hoá với MIME chuẩn. Sau khi tải, hãy vào Cài đặt iOS > Đã tải về hồ sơ > Cài đặt.")
            }
            
            NBSection("Hướng dẫn kích hoạt trên iOS") {
                VStack(alignment: .leading, spacing: 10) {
                    _stepRow(number: "1", text: "Nhấn nút 'Cài đặt Hồ sơ' ở trên để mở qua Safari hoặc chọn 'Lưu vào Tệp'.")
                    _stepRow(number: "2", text: "Khi Safari hiển thị hộp thoại, bấm 'Cho phép' để tải hồ sơ cấu hình.")
                    _stepRow(number: "3", text: "Vào Cài đặt của iPhone/iPad > chọn 'Đã tải về hồ sơ' (ngay dưới tên Apple ID).")
                    _stepRow(number: "4", text: "Nhấn 'Cài đặt' ở góc trên bên phải và nhập mật mã mở máy của bạn.")
                    _stepRow(number: "5", text: "Vào Cài đặt > Cài đặt chung > VPN & Quản lý thiết bị > DNS > Chọn cấu hình LemonSign Anti-Revoke.")
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
    
    private func _installProfileLocally() {
        isStartingServer = true
        AntiRevokeLocalServer.shared.startAndServe { port in
            isStartingServer = false
            if let port = port, let url = URL(string: "http://127.0.0.1:\(port)/anti-revoke.mobileconfig") {
                UIApplication.shared.open(url)
            } else {
                // Fallback to GitHub URL
                _installFromGitHub()
            }
        }
    }
    
    private func _shareProfileFile() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("LemonSign_AntiRevoke.mobileconfig")
        do {
            try AntiRevokeProfile.data.write(to: tempURL)
            UIActivityViewController.show(activityItems: [tempURL])
        } catch {
            print("[AntiRevokeView] Failed to write temp mobileconfig: \(error)")
        }
    }
    
    private func _installFromGitHub() {
        if let url = URL(string: gitHubFallbackURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func _copyHosts() {
        UIPasteboard.general.string = blockedHosts.joined(separator: "\n")
        showingCopiedAlert = true
    }
}
