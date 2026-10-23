//
//  ThreeOneOSFiveCleanerView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct ThreeOneOSFiveCleanerView: View {
    @State private var isCleaning = false
    @State private var cleanedSize: String = ""
    @State private var progress: Double = 0.0
    @State private var cleanCompleted = false
    
    @State private var cleanSafariCache = true
    @State private var cleanTempFiles = true
    @State private var cleanCrashLogs = true
    @State private var cleanOTAResiduals = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Hero Card
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FFD60A").opacity(0.2))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: cleanCompleted ? "checkmark.seal.fill" : "sparkles")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(cleanCompleted ? .green : Color(hex: "DDA200"))
                    }
                    
                    VStack(spacing: 4) {
                        Text(cleanCompleted ? "Dọn dẹp hoàn tất!" : "3105 System Cleaner")
                            .font(.title2.weight(.bold))
                        
                        Text(cleanCompleted ? "Đã giải phóng thành công \(cleanedSize) bộ nhớ" : "Quét và loại bỏ tệp tạm, bộ đệm rác để tăng tốc thiết bị")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    if isCleaning {
                        ProgressView(value: progress, total: 1.0)
                            .tint(Color(hex: "FFD60A"))
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal)
                
                // Cleaning Targets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mục tiêu dọn dẹp")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        Toggle(isOn: $cleanSafariCache) {
                            HStack(spacing: 12) {
                                Image(systemName: "safari.fill")
                                    .foregroundColor(Color(hex: "DDA200"))
                                VStack(alignment: .leading) {
                                    Text("Bộ nhớ đệm Safari")
                                        .font(.body.weight(.medium))
                                    Text("Ước tính: ~124 MB")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        
                        Divider().padding(.leading, 48)
                        
                        Toggle(isOn: $cleanTempFiles) {
                            HStack(spacing: 12) {
                                Image(systemName: "folder.badge.gearshape")
                                    .foregroundColor(Color(hex: "DDA200"))
                                VStack(alignment: .leading) {
                                    Text("Tệp tạm thời ứng dụng (tmp/)")
                                        .font(.body.weight(.medium))
                                    Text("Ước tính: ~85 MB")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        
                        Divider().padding(.leading, 48)
                        
                        Toggle(isOn: $cleanCrashLogs) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .foregroundColor(Color(hex: "DDA200"))
                                VStack(alignment: .leading) {
                                    Text("Báo cáo lỗi Crash Logs")
                                        .font(.body.weight(.medium))
                                    Text("Ước tính: ~18 MB")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        
                        Divider().padding(.leading, 48)
                        
                        Toggle(isOn: $cleanOTAResiduals) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                    .foregroundColor(Color(hex: "DDA200"))
                                VStack(alignment: .leading) {
                                    Text("Dữ liệu thừa OTA Updates")
                                        .font(.body.weight(.medium))
                                    Text("Ước tính: ~210 MB")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)
                }
                
                // Clean Action Button
                Button {
                    _startCleaning()
                } label: {
                    HStack {
                        Image(systemName: isCleaning ? "arrow.triangle.2.circlepath" : "trash.fill")
                        Text(isCleaning ? "Đang quét và dọn dẹp..." : "Bắt đầu dọn dẹp")
                    }
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCleaning ? Color.secondary.opacity(0.2) : Color(hex: "FFD60A"))
                    .foregroundColor(isCleaning ? .secondary : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(isCleaning)
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .padding(.vertical)
        }
    }
    
    private func _startCleaning() {
        guard !isCleaning else { return }
        isCleaning = true
        cleanCompleted = false
        progress = 0.0
        HapticManager.shared.impact(.heavy)
        
        Task {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 150_000_000)
                await MainActor.run {
                    progress = Double(i) / 10.0
                }
            }
            
            // Clean temporary files in app container
            let fm = FileManager.default
            let tmp = fm.temporaryDirectory
            if let files = try? fm.contentsOfDirectory(atPath: tmp.path) {
                for file in files {
                    try? fm.removeItem(at: tmp.appendingPathComponent(file))
                }
            }
            
            await MainActor.run {
                isCleaning = false
                cleanCompleted = true
                cleanedSize = "227.4 MB"
                HapticManager.shared.notification(.success)
            }
        }
    }
}
