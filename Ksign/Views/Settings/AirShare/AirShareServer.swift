//
//  AirShareServer.swift
//  LemonSign
//
//  Created by Kasumi on 24.10.2026.
//

import Foundation
import Network
import UIKit

final class AirShareServer: ObservableObject {
    static let shared = AirShareServer()
    
    @Published var isRunning: Bool = false
    @Published var lastAction: String = "Sẵn sàng kết nối"
    @Published var uploadCount: Int = 0
    
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.lemonsign.airshare.server", qos: .userInitiated)
    let port: UInt16 = 8088
    
    private init() {}
    
    func start(completion: ((Bool) -> Void)? = nil) {
        stop()
        
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            
            guard let nwPort = NWEndpoint.Port(rawValue: port) else {
                completion?(false)
                return
            }
            
            let newListener = try NWListener(using: params, on: nwPort)
            self.listener = newListener
            
            newListener.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            
            newListener.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        self?.isRunning = true
                        self?.lastAction = "Máy chủ đang chạy trên cổng \(self?.port ?? 8088)"
                        completion?(true)
                    case .failed(let error):
                        print("[AirShareServer] Failed: \(error)")
                        self?.isRunning = false
                        self?.lastAction = "Lỗi khởi động: \(error.localizedDescription)"
                        completion?(false)
                    case .cancelled:
                        self?.isRunning = false
                        self?.lastAction = "Máy chủ đã dừng"
                    default:
                        break
                    }
                }
            }
            
            newListener.start(queue: queue)
        } catch {
            print("[AirShareServer] Could not initialize NWListener: \(error)")
            DispatchQueue.main.async {
                self.isRunning = false
                self.lastAction = "Không thể mở cổng 8088: \(error.localizedDescription)"
                completion?(false)
            }
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
        DispatchQueue.main.async {
            self.isRunning = false
            self.lastAction = "Máy chủ đã tắt"
        }
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        readRequest(from: connection, accumulatedData: Data())
    }
    
    private func readRequest(from connection: NWConnection, accumulatedData: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            var current = accumulatedData
            if let data = data, !data.isEmpty {
                current.append(data)
            }
            
            // Check if HTTP header is complete (\r\n\r\n)
            if let headerEndRange = current.range(of: Data("\r\n\r\n".utf8)) {
                let headerData = current.subdata(in: 0..<headerEndRange.lowerBound)
                let bodyData = current.subdata(in: headerEndRange.upperBound..<current.count)
                
                guard let headerString = String(data: headerData, encoding: .utf8) else {
                    self.sendResponse(connection, status: "400 Bad Request", body: "Invalid UTF-8 request")
                    return
                }
                
                let lines = headerString.components(separatedBy: "\r\n")
                guard let requestLine = lines.first else {
                    self.sendResponse(connection, status: "400 Bad Request", body: "Empty request")
                    return
                }
                
                let parts = requestLine.components(separatedBy: " ")
                guard parts.count >= 2 else {
                    self.sendResponse(connection, status: "400 Bad Request", body: "Malformed request line")
                    return
                }
                
                let method = parts[0].uppercased()
                let target = parts[1]
                
                if method == "GET" {
                    self.handleGet(connection: connection, target: target)
                } else if method == "POST" {
                    // Extract Content-Length
                    var contentLength = 0
                    for line in lines {
                        let lower = line.lowercased()
                        if lower.hasPrefix("content-length:") {
                            let value = line.dropFirst("content-length:".count).trimmingCharacters(in: .whitespaces)
                            contentLength = Int(value) ?? 0
                        }
                    }
                    self.handlePost(connection: connection, target: target, initialBody: bodyData, totalExpectedBytes: contentLength)
                } else {
                    self.sendResponse(connection, status: "405 Method Not Allowed", body: "Method not supported")
                }
            } else if isComplete || error != nil {
                connection.cancel()
            } else {
                // Continue reading headers
                self.readRequest(from: connection, accumulatedData: current)
            }
        }
    }
    
    // MARK: - GET Handler
    private func handleGet(connection: NWConnection, target: String) {
        if target == "/" || target == "/index.html" {
            let html = generateDashboardHTML()
            sendResponse(connection, status: "200 OK", contentType: "text/html; charset=utf-8", bodyData: Data(html.utf8))
        } else if target.hasPrefix("/download") {
            let components = URLComponents(string: target)
            let fileName = components?.queryItems?.first(where: { $0.name == "file" })?.value ?? ""
            let sanitized = (fileName as NSString).lastPathComponent
            
            let fileURL = URL.documentsDirectory.appendingPathComponent(sanitized)
            if FileManager.default.fileExists(atPath: fileURL.path),
               let fileData = try? Data(contentsOf: fileURL) {
                let headers = [
                    "Content-Type: application/octet-stream",
                    "Content-Disposition: attachment; filename=\"\(sanitized)\"",
                    "Content-Length: \(fileData.count)"
                ]
                sendResponse(connection, status: "200 OK", customHeaders: headers, bodyData: fileData)
                DispatchQueue.main.async {
                    self.lastAction = "Đã gửi tệp: \(sanitized)"
                }
            } else {
                sendResponse(connection, status: "404 Not Found", body: "Tệp không tồn tại trên thiết bị")
            }
        } else {
            sendResponse(connection, status: "404 Not Found", body: "Trang không tồn tại")
        }
    }
    
    // MARK: - POST Handler
    private func handlePost(connection: NWConnection, target: String, initialBody: Data, totalExpectedBytes: Int) {
        let components = URLComponents(string: target)
        var fileName = components?.queryItems?.first(where: { $0.name == "file" })?.value ?? "uploaded_\(Int(Date().timeIntervalSince1970)).ipa"
        fileName = (fileName as NSString).lastPathComponent
        if !fileName.lowercased().hasSuffix(".ipa") && !fileName.lowercased().hasSuffix(".tipa") {
            fileName += ".ipa"
        }
        
        let destinationURL = URL.documentsDirectory.appendingPathComponent(fileName)
        
        FileManager.default.createFile(atPath: destinationURL.path, contents: nil, attributes: nil)
        guard let fileHandle = try? FileHandle(forWritingTo: destinationURL) else {
            sendResponse(connection, status: "500 Internal Server Error", body: "Could not create file on device")
            return
        }
        
        var bytesWritten = 0
        if !initialBody.isEmpty {
            fileHandle.write(initialBody)
            bytesWritten += initialBody.count
        }
        
        if bytesWritten >= totalExpectedBytes && totalExpectedBytes > 0 {
            try? fileHandle.close()
            self.finishUpload(connection: connection, fileName: fileName)
        } else {
            receiveRemainingBody(connection: connection, fileHandle: fileHandle, bytesWritten: bytesWritten, totalExpectedBytes: totalExpectedBytes, fileName: fileName)
        }
    }
    
    private func receiveRemainingBody(connection: NWConnection, fileHandle: FileHandle, bytesWritten: Int, totalExpectedBytes: Int, fileName: String) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            var newWritten = bytesWritten
            if let data = data, !data.isEmpty {
                fileHandle.write(data)
                newWritten += data.count
            }
            
            if newWritten >= totalExpectedBytes || isComplete || error != nil {
                try? fileHandle.close()
                self.finishUpload(connection: connection, fileName: fileName)
            } else {
                self.receiveRemainingBody(connection: connection, fileHandle: fileHandle, bytesWritten: newWritten, totalExpectedBytes: totalExpectedBytes, fileName: fileName)
            }
        }
    }
    
    private func finishUpload(connection: NWConnection, fileName: String) {
        DispatchQueue.main.async {
            self.uploadCount += 1
            self.lastAction = "Đã nhận thành công: \(fileName)"
            NotificationCenter.default.post(name: NSNotification.Name("AirShareFileReceived"), object: fileName)
        }
        
        let jsonResponse = """
        {"success": true, "message": "Uploaded \(fileName) successfully", "fileName": "\(fileName)"}
        """
        sendResponse(connection, status: "200 OK", contentType: "application/json; charset=utf-8", bodyData: Data(jsonResponse.utf8))
    }
    
    // MARK: - HTTP Helpers
    private func sendResponse(_ connection: NWConnection, status: String, contentType: String = "text/plain; charset=utf-8", customHeaders: [String] = [], body: String) {
        sendResponse(connection, status: status, contentType: contentType, customHeaders: customHeaders, bodyData: Data(body.utf8))
    }
    
    private func sendResponse(_ connection: NWConnection, status: String, contentType: String = "text/plain; charset=utf-8", customHeaders: [String] = [], bodyData: Data) {
        var headerLines = [
            "HTTP/1.1 \(status)",
            "Content-Type: \(contentType)",
            "Content-Length: \(bodyData.count)",
            "Access-Control-Allow-Origin: *",
            "Connection: close"
        ]
        headerLines.append(contentsOf: customHeaders)
        headerLines.append("\r\n")
        
        var packet = Data(headerLines.joined(separator: "\r\n").utf8)
        packet.append(bodyData)
        
        connection.send(content: packet, completion: .contentProcessed({ _ in
            connection.cancel()
        }))
    }
    
    // MARK: - HTML Dashboard
    private func generateDashboardHTML() -> String {
        let documentsURL = URL.documentsDirectory
        let fileManager = FileManager.default
        var ipaFiles: [(name: String, size: String)] = []
        
        if let files = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) {
            for file in files {
                let ext = file.pathExtension.lowercased()
                if ext == "ipa" || ext == "tipa" {
                    let sizeBytes = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    let sizeMB = String(format: "%.1f MB", Double(sizeBytes) / (1024.0 * 1024.0))
                    ipaFiles.append((name: file.lastPathComponent, size: sizeMB))
                }
            }
        }
        
        var rowsHTML = ""
        if ipaFiles.isEmpty {
            rowsHTML = "<tr><td colspan='3' style='text-align:center;color:#888;padding:24px;'>Chưa có file IPA nào trong thư mục Tệp của LemonSign.</td></tr>"
        } else {
            for file in ipaFiles {
                let encodedName = file.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? file.name
                rowsHTML += """
                <tr>
                    <td style='font-weight:600;word-break:break-all;'>\(file.name)</td>
                    <td style='color:#bbb;white-space:nowrap;'>\(file.size)</td>
                    <td style='text-align:right;'>
                        <a href='/download?file=\(encodedName)' class='btn btn-dl'>Tải về máy tính</a>
                    </td>
                </tr>
                """
            }
        }
        
        return """
        <!DOCTYPE html>
        <html lang="vi">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>LemonSign AirShare</title>
            <style>
                :root {
                    --lemon: #FFD60A;
                    --bg: #121316;
                    --card: #1c1d22;
                    --text: #f5f5f7;
                    --border: #2a2c33;
                }
                * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
                body { background: var(--bg); color: var(--text); padding: 24px 16px; }
                .container { max-width: 760px; margin: 0 auto; }
                header { text-align: center; margin-bottom: 28px; }
                .logo { font-size: 42px; margin-bottom: 6px; }
                h1 { font-size: 26px; color: var(--lemon); font-weight: 800; }
                p.sub { color: #8e8e93; font-size: 14px; margin-top: 4px; }
                .badge { display: inline-block; background: rgba(255, 214, 10, 0.15); color: var(--lemon); font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 999px; margin-top: 10px; border: 1px solid rgba(255, 214, 10, 0.3); }
                .card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 20px; margin-bottom: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); }
                .card-title { font-size: 17px; font-weight: 700; color: #fff; margin-bottom: 14px; display: flex; align-items: center; gap: 8px; }
                
                /* Dropzone */
                .dropzone { border: 2px dashed #444; border-radius: 12px; padding: 36px 20px; text-align: center; background: rgba(255, 255, 255, 0.02); cursor: pointer; transition: all 0.2s ease; }
                .dropzone.hover { border-color: var(--lemon); background: rgba(255, 214, 10, 0.05); }
                .dropzone p { color: #aaa; font-size: 14px; margin-top: 8px; }
                .btn { background: var(--lemon); color: #000; font-weight: 700; padding: 10px 20px; border-radius: 10px; text-decoration: none; border: none; cursor: pointer; display: inline-block; font-size: 14px; transition: transform 0.1s; }
                .btn:active { transform: scale(0.97); }
                .btn-dl { background: rgba(255, 214, 10, 0.2); color: var(--lemon); padding: 6px 14px; font-size: 13px; }
                .btn-dl:hover { background: var(--lemon); color: #000; }
                
                /* Progress */
                #progressContainer { display: none; margin-top: 16px; }
                .progress-bar-bg { width: 100%; height: 10px; background: #333; border-radius: 5px; overflow: hidden; margin-top: 6px; }
                .progress-bar-fill { height: 100%; background: var(--lemon); width: 0%; transition: width 0.1s; }
                
                /* Table */
                table { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 14px; }
                th { text-align: left; color: #888; font-weight: 600; padding: 8px 10px; border-bottom: 1px solid var(--border); }
                td { padding: 12px 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
                
                #toast { position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%); background: #28a745; color: #fff; padding: 12px 24px; border-radius: 30px; font-weight: 600; font-size: 14px; display: none; box-shadow: 0 4px 16px rgba(0,0,0,0.4); }
            </style>
        </head>
        <body>
            <div class="container">
                <header>
                    <div class="logo">🍋</div>
                    <h1>LemonSign AirShare</h1>
                    <p class="sub">Truyền tải và quản lý tệp IPA qua mạng Wi-Fi nội bộ</p>
                    <div class="badge">🟢 Mạng LAN Đang Hoạt Động</div>
                </header>
                
                <!-- Upload Box -->
                <div class="card">
                    <div class="card-title">📤 Tải lên Tệp IPA vào LemonSign</div>
                    <div class="dropzone" id="dropzone" onclick="document.getElementById('fileInput').click()">
                        <div style="font-size: 32px;">📦</div>
                        <strong style="color:#fff;display:block;margin-top:8px;">Nhấn để chọn tệp .IPA hoặc kéo thả vào đây</strong>
                        <p>Tệp sẽ được chuyển thẳng vào mục 'Tệp' trên iPhone/iPad để ký ngay</p>
                        <input type="file" id="fileInput" accept=".ipa,.tipa" style="display:none;" onchange="handleFileSelect(this.files)">
                    </div>
                    
                    <div id="progressContainer">
                        <div style="display:flex;justify-content:space-between;font-size:13px;color:#aaa;">
                            <span id="progressText">Đang tải lên...</span>
                            <span id="progressPercent">0%</span>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill" id="progressBar"></div>
                        </div>
                    </div>
                </div>
                
                <!-- Download Box -->
                <div class="card">
                    <div class="card-title">📥 Tệp IPA Trên Thiết Bị (Tải về máy tính)</div>
                    <table>
                        <thead>
                            <tr>
                                <th>Tên Tệp</th>
                                <th>Kích thước</th>
                                <th style="text-align:right;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            \(rowsHTML)
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div id="toast"></div>
            
            <script>
                const dropzone = document.getElementById('dropzone');
                ['dragenter', 'dragover'].forEach(n => dropzone.addEventListener(n, e => { e.preventDefault(); dropzone.classList.add('hover'); }));
                ['dragleave', 'drop'].forEach(n => dropzone.addEventListener(n, e => { e.preventDefault(); dropzone.classList.remove('hover'); }));
                dropzone.addEventListener('drop', e => {
                    if (e.dataTransfer.files.length > 0) handleFileSelect(e.dataTransfer.files);
                });
                
                function handleFileSelect(files) {
                    if (!files || files.length === 0) return;
                    const file = files[0];
                    uploadFile(file);
                }
                
                function uploadFile(file) {
                    const pContainer = document.getElementById('progressContainer');
                    const pBar = document.getElementById('progressBar');
                    const pPercent = document.getElementById('progressPercent');
                    const pText = document.getElementById('progressText');
                    
                    pContainer.style.display = 'block';
                    pText.textContent = 'Đang tải lên ' + file.name + '...';
                    
                    const xhr = new XMLHttpRequest();
                    xhr.open('POST', '/upload?file=' + encodeURIComponent(file.name), true);
                    
                    xhr.upload.onprogress = e => {
                        if (e.lengthComputable) {
                            const percent = Math.round((e.loaded / e.total) * 100);
                            pBar.style.width = percent + '%';
                            pPercent.textContent = percent + '%';
                        }
                    };
                    
                    xhr.onload = () => {
                        if (xhr.status === 200) {
                            showToast('✅ Đã chuyển thành công ' + file.name + ' vào LemonSign!');
                            setTimeout(() => { window.location.reload(); }, 1500);
                        } else {
                            alert('Lỗi tải lên: ' + xhr.responseText);
                            pContainer.style.display = 'none';
                        }
                    };
                    
                    xhr.onerror = () => {
                        alert('Lỗi mất kết nối mạng với iPhone/iPad.');
                        pContainer.style.display = 'none';
                    };
                    
                    xhr.send(file);
                }
                
                function showToast(msg) {
                    const t = document.getElementById('toast');
                    t.textContent = msg;
                    t.style.display = 'block';
                    setTimeout(() => { t.style.display = 'none'; }, 3500);
                }
            </script>
        </body>
        </html>
        """
    }
}
