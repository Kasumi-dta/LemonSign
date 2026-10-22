//
//  AboutNyaView.swift
//  Ksign
//
//  Created by Nagata Asami on 23/5/25.
//

import SwiftUI
import NimbleViews
import NimbleJSON

// MARK: - View
struct AboutNyaView: View {
	private let _dataService = NBFetchService()
	
	@State private var shouldShowPatchNotes = false
	
	// MARK: Body
	var body: some View {
		NBList(.localized("About")) {
            Section {
                VStack {
                    Image(uiImage: (UIImage(named: Bundle.main.iconFileName ?? ""))! )
                        .appIconStyle(size: 72)
                    
                    Text(Bundle.main.exec)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.accent)
                    
                    HStack(spacing: 4) {
                        Text("Version")
                        Text(Bundle.main.version)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    
                    Button {
                        _showPatchNotes()
                    } label: {
                        Text("Show patch notes").bg()
                    }
                    .font(.footnote)
                    .padding(.top, 4)
                    .tint(.accent)

                    Button {
                        UpdateManager.shared.checkForUpdates(isManualCheck: true)
                    } label: {
                        Text("Check for Updates").bg()
                    }
                    .font(.footnote)
                    .padding(.top, 2)
                    .tint(.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(EmptyView())
			
			NBSection(.localized("Credits")) {
				_credit(name: "Kasumi", desc: "Developer", github: "Kasumi-dta")
			}
			
			NBSection("Special thanks!") {
				Group {
					Text(.localized("This couldn't have been done without the original Feather devs! ❤️"))
						.foregroundStyle(.secondary)
						.padding(.vertical, 2)
				}
				.transition(.slide)
			}
            
            NBSection("Acknowledgements") {
                NavigationLink(destination: AboutView()) {
                    HStack {
                        Text("About the original Feather")
                        Spacer()
                    }
                }
            } footer: {
                Text(Bundle.main.bundleIdentifier ?? "")
            }
		}
	}
	
	private func _showPatchNotes() {
		UIAlertController.showAlertWithOk(
			title: .localized("From Kasumi, Version \(Bundle.main.version) (Beta 3)"),
			message: .localized("Bản cập nhật LemonSign Beta 3 (v1.6.3.2):\n\n- 🛡️ Bảo lưu toàn vẹn 100% chứng chỉ đã nhập (.p12 / .mobileprovision) và cấu hình khi cập nhật.\n- ⚡ LemonTurbo Engine tự động: Ký siêu tốc tức thì, loại bỏ hoàn toàn các popup xác nhận phiền phức.\n- 📬 Hòm thư thông báo trên Trang chủ & Thư viện: Kiểm tra Có gì mới và cập nhật một chạm.\n- 🔄 Hoàn thiện hệ thống cập nhật tự động (In-App Updater): Hỗ trợ tự cài đè qua OTA nội bộ.\n- 🌐 Hỗ trợ đa ngôn ngữ hoàn chỉnh (Tiếng Việt & English).\n- 🚀 Tăng tốc độ truyền tải Payload và cài đặt OTA cực nhanh."),
			isCancel: true,
			thankYou: true
		)
	}
}

// MARK: - Extension: view
extension AboutNyaView {
	@ViewBuilder
	private func _credit(
		name: String?,
		desc: String?,
		github: String
	) -> some View {
		FRIconCellView(
			title: name ?? github,
			subtitle: desc ?? "",
			iconUrl: URL(string: "https://github.com/\(github).png")!,
			trailing: AnyView(
				Image(systemName: "arrow.up.right")
					.foregroundStyle(.secondary)
			)
		)
		.onTapGesture {
			if let url = URL(string: "https://github.com/\(github)") {
				UIApplication.shared.open(url)
			}
		}
	}
}
