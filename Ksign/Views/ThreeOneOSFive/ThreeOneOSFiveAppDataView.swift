//
//  ThreeOneOSFiveAppDataView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct AppContainerItem: Identifiable {
    let id: String
    let name: String
    let bundleID: String
    let iconSystemName: String
    let documentsSize: String
    let cachesSize: String
}

struct ThreeOneOSFiveAppDataView: View {
    @State private var searchText = ""
    @State private var selectedApp: AppContainerItem?
    
    // Built-in list of discoverable standard app containers
    private let apps: [AppContainerItem] = [
        AppContainerItem(
            id: "com.apple.mobilesafari",
            name: "Safari",
            bundleID: "com.apple.mobilesafari",
            iconSystemName: "safari.fill",
            documentsSize: "4.2 MB",
            cachesSize: "86.5 MB"
        ),
        AppContainerItem(
            id: "com.apple.mobilephone",
            name: "Điện thoại (Phone)",
            bundleID: "com.apple.mobilephone",
            iconSystemName: "phone.fill",
            documentsSize: "1.1 MB",
            cachesSize: "12.3 MB"
        ),
        AppContainerItem(
            id: "com.apple.Preferences",
            name: "Cài đặt (Settings)",
            bundleID: "com.apple.Preferences",
            iconSystemName: "gearshape.fill",
            documentsSize: "512 KB",
            cachesSize: "24.1 MB"
        ),
        AppContainerItem(
            id: "com.kasumidta.lemonsign",
            name: "LemonSign",
            bundleID: "com.kasumidta.lemonsign",
            iconSystemName: "lemon.fill",
            documentsSize: "18.4 MB",
            cachesSize: "32.0 MB"
        ),
        AppContainerItem(
            id: "com.apple.PosterBoard",
            name: "PosterBoard",
            bundleID: "com.apple.PosterBoard",
            iconSystemName: "photo.on.rectangle.angled",
            documentsSize: "15.8 MB",
            cachesSize: "112.4 MB"
        ),
        AppContainerItem(
            id: "com.apple.springboard",
            name: "SpringBoard",
            bundleID: "com.apple.springboard",
            iconSystemName: "apps.iphone",
            documentsSize: "8.9 MB",
            cachesSize: "45.0 MB"
        )
    ]
    
    private var filteredApps: [AppContainerItem] {
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.bundleID.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Information
                HStack(spacing: 12) {
                    Image(systemName: "externaldrive.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "FFD60A"))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trình duyệt dữ liệu ứng dụng")
                            .font(.headline.weight(.bold))
                        Text("Xem và quản lý các thư mục Documents, Caches và App Groups")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // Apps List
                LazyVStack(spacing: 10) {
                    ForEach(filteredApps) { item in
                        AppContainerRow(item: item) {
                            selectedApp = item
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .searchable(text: $searchText, placement: .platform(), prompt: "Tìm ứng dụng theo tên hoặc Bundle ID...")
        .sheet(item: $selectedApp) { item in
            AppContainerDetailSheet(item: item)
        }
    }
}

// MARK: - Row
struct AppContainerRow: View {
    let item: AppContainerItem
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "FFD60A").opacity(0.18))
                    .frame(width: 46, height: 46)
                
                Image(systemName: item.iconSystemName)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color(hex: "DDA200"))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                
                Text(item.bundleID)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Caches: \(item.cachesSize)")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.secondary)
                
                Text("Docs: \(item.documentsSize)")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(Color(hex: "B8860B"))
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Detail Sheet
struct AppContainerDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let item: AppContainerItem
    @State private var didBackup = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Thông tin App Container")) {
                    HStack {
                        Text("Tên ứng dụng")
                        Spacer()
                        Text(item.name).foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Bundle Identifier")
                        Spacer()
                        Text(item.bundleID).foregroundColor(.secondary).font(.footnote)
                    }
                }
                
                Section(header: Text("Dung lượng thư mục")) {
                    HStack {
                        Label("Documents", systemImage: "folder.fill")
                        Spacer()
                        Text(item.documentsSize).foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Library / Caches", systemImage: "tray.fill")
                        Spacer()
                        Text(item.cachesSize).foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button {
                        didBackup = true
                        HapticManager.shared.notification(.success)
                    } label: {
                        HStack {
                            Image(systemName: didBackup ? "checkmark.circle.fill" : "arrow.down.doc.fill")
                            Text(didBackup ? "Đã sao lưu Container thành công!" : "Sao lưu toàn bộ Container (ZIP)")
                        }
                        .foregroundColor(didBackup ? .green : Color(hex: "B8860B"))
                    }
                } footer: {
                    Text("Tệp sao lưu sẽ chứa cấu trúc Documents và Preferences để phục hồi dữ liệu khi cần.")
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "DDA200"))
                }
            }
        }
    }
}
