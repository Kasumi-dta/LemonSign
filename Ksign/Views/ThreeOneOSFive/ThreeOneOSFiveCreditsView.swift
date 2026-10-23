//
//  ThreeOneOSFiveCreditsView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct ThreeOneOSFiveCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // Section: App & Author Identity
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "puzzlepiece.extension.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "FFD60A"))
                            .padding(.top, 8)
                        
                        Text("3105 for LemonSign")
                            .font(.title2.weight(.bold))
                        
                        Text("Phát triển & Thiết kế bởi YangJiii")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Text("Bản quyền © 2024–2026 YangJiii")
                                .font(.caption.weight(.medium))
                                .foregroundColor(Color(hex: "B8860B"))
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("GPL v3.0")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "FFD60A").opacity(0.2))
                                .foregroundColor(Color(hex: "8B6914"))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                
                // Section: Official Links
                Section("Liên kết chính thức") {
                    Link(destination: URL(string: "https://x.com/duongduong0908")!) {
                        HStack {
                            Image(systemName: "at")
                                .foregroundColor(Color(hex: "FFD60A"))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tác giả: YangJiii (@duongduong0908)")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text("Theo dõi tác giả chính thức trên X / Twitter")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/YangJiiii/3105")!) {
                        HStack {
                            Image(systemName: "curlybraces.square.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mã nguồn dự án 3105 (GitHub)")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text("https://github.com/YangJiiii/3105")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://t.me/ioscrackvn")!) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color(hex: "FFD60A"))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cộng Đồng IOSVN")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text("Cộng đồng nghiên cứu iOS & Sideloading Việt Nam")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Section: Third Party Credits
                Section("Ghi công đóng góp kỹ thuật (Credits)") {
                    creditItem(
                        name: "YangJiii",
                        role: "Nhà phát triển chính & thiết kế toàn bộ kiến trúc 3105",
                        url: "https://x.com/duongduong0908"
                    )
                    
                    creditItem(
                        name: "0xjohnnydev (FilzaSlop)",
                        role: "MHA-C2, dò container dữ liệu ứng dụng & sandbox escape",
                        url: "https://github.com/0xjohnnydev/FilzaSlop"
                    )
                    
                    creditItem(
                        name: "LeminLimez (Pocket Poster / Nugget)",
                        role: "Pocket Poster, Nugget và tiêu chuẩn định dạng .tendies",
                        url: "https://github.com/leminlimez/Pocket-Poster"
                    )
                    
                    creditItem(
                        name: "CrazyMind90",
                        role: "Nền tảng sandbox escape và theme dialer bàn phím",
                        url: "https://github.com/CrazyMind90"
                    )
                    
                    creditItem(
                        name: "forcequitOS",
                        role: "Khai thác bad_query cho hệ thống",
                        url: "https://github.com/forcequitOS"
                    )
                    
                    creditItem(
                        name: "opa334",
                        role: "Tác giả Dopamine jailbreak, nền tảng kexploit",
                        url: "https://github.com/opa334"
                    )
                }
                
                // Section: Legal & Disclaimer
                Section("Tuyên bố pháp lý & Bản quyền") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mã nguồn gốc của 3105 được phát hành theo giấy phép mã nguồn mở GNU General Public License v3.0 (GPL-3.0). Mọi quyền tác giả thuộc về YangJiii và các cộng tác viên tương ứng.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("3105 là phần mềm nghiên cứu quản lý thiết bị cá nhân trên các thiết bị do bạn sở hữu. LemonSign bảo toàn nguyên vẹn tính minh bạch, ghi công và bản quyền của tác giả gốc.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Bản quyền tác giả")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xong") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "DDA200"))
                }
            }
        }
    }
    
    @ViewBuilder
    private func creditItem(name: String, role: String, url: String) -> some View {
        if let linkUrl = URL(string: url) {
            Link(destination: linkUrl) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                        Text(role)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
