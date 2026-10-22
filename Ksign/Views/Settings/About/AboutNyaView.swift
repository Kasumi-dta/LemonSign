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
                        UpdateManager.shared.checkForUpdates(isManualCheck: true)
                    } label: {
                        Text("Check for Updates").bg()
                    }
                    .font(.footnote)
                    .padding(.top, 4)
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
