//
//  InstallationView.swift
//  Feather
//
//  Created by samara on 3.06.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct InstallationView: View {
    @AppStorage("Feather.installationMethod") private var _installationMethod: Int = 0
    @State private var _showMethodChangedAlert = false

    private var _installationMethods: [String] {
        var methods = [
            String.localized("Server"),
            String.localized("idevice")
        ]
        if TrollStoreHelper.isTrollStoreAvailable {
            methods.append("TrollStore")
        }
        return methods
    }
    
    // MARK: Body
    var body: some View {
        NBList(.localized("Installation")) {
            Section {
                Picker(.localized("Installation Type"), systemImage: "arrow.down.app", selection: $_installationMethod) {
                    ForEach(_installationMethods.indices, id: \.description) { index in
                        Text(_installationMethods[index]).tag(index)
                    }
                }
            } footer: {
                if _installationMethod == 0 {
                    Text("Máy chủ nội bộ (Khuyên dùng): Sử dụng HTTPS localhost để cài đặt ứng dụng OTA qua itms-services://.")
                } else {
                    Text("IDevice (Nâng cao): Sử dụng VPN và tệp ghép đôi (pairing file). Không yêu cầu chứng chỉ SSL.")
                }
            }
            
            if _installationMethod == 0 {
                ServerView()
            } else if _installationMethod == 1 {
                TunnelView()
            }
        }
        .onChange(of: _installationMethod) { newValue in
            guard newValue == 1 else { return }
            _showMethodChangedAlert = true
        }
        .alert(.localized("Advanced Installation Method"), isPresented: $_showMethodChangedAlert) {
            Button(.localized("Switch Back"), role: .destructive) {
                _installationMethod = 0
            }
            Button(.localized("OK"), role: .cancel) {}
        } message: {
            Text(.localized("idevice warning"))
        }


        .animation(.default, value: _installationMethod)
    }
}

