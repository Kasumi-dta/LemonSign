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
		.onAppear {
			// Show patch notes when navigating to this view if they haven't been shown before
			if !UserDefaults.standard.bool(forKey: "patchNotesShown") {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					_showPatchNotes()
					UserDefaults.standard.set(true, forKey: "patchNotesShown")
				}
			}
		}
	}
	
	private func _showPatchNotes() {
		UIAlertController.showAlertWithOk(
			title: .localized("From Kasumi, Version \(Bundle.main.version) (Beta 2)"),
			message: .localized("Bản cập nhật LemonSign Beta 2 mang đến:\n\n- ⚡ LemonTurbo Engine: Tận dụng tối đa đa nhân CPU thiết bị để tăng tốc độ ký và băm file song song (nhanh hơn 3x - 5x).\n- 🚀 Tối ưu luồng giải nén & đóng gói IPA siêu tốc (High-Priority CPU + Fast compression).\n- 🔔 Bổ sung Popup thông báo huy động tài nguyên phần cứng thiết bị khi ký.\n- 🔄 In-App Auto-Updater: Tự động kiểm tra và cập nhật ứng dụng từ xa trực tuyến qua GitHub Release.\n- 🌐 Máy chủ OTA thông minh: Tự động chuyển đổi máy chủ và nhắc cập nhật chứng chỉ SSL khi lỗi payload.\n- 🍋 Giao diện vàng chanh Lemon Yellow đặc trưng & Icon Pixel Lemon nghệ thuật."),
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
