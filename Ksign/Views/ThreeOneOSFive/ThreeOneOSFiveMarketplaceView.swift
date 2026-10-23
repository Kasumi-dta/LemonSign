//
//  ThreeOneOSFiveMarketplaceView.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import SwiftUI
import NimbleViews

struct ThreeOneOSFiveMarketplaceView: View {
    @ObservedObject var store = ThreeOneStore.shared
    @State private var selectedKind: ThreeOnePackageKind = .all
    @State private var searchText: String = ""
    @State private var selectedPackage: ThreeOnePackage?
    
    private var filteredPackages: [ThreeOnePackage] {
        store.packages.filter { pkg in
            let matchesKind = (selectedKind == .all || pkg.kind == selectedKind)
            let matchesSearch = searchText.isEmpty ||
                pkg.name.localizedCaseInsensitiveContains(searchText) ||
                pkg.author.localizedCaseInsensitiveContains(searchText) ||
                pkg.description.localizedCaseInsensitiveContains(searchText)
            return matchesKind && matchesSearch
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ThreeOnePackageKind.allCases) { kind in
                            Button {
                                selectedKind = kind
                                HapticManager.shared.impact(.light)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: kind.iconName)
                                    Text(kind.rawValue)
                                }
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedKind == kind ? Color(hex: "FFD60A") : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundColor(selectedKind == kind ? .black : .primary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(selectedKind == kind ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 4)
                
                // Featured Banner
                if selectedKind == .all && searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Dành cho bạn")
                                .font(.title3.weight(.bold))
                            Spacer()
                            Text("Kho 3105 v2.0")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(store.packages.prefix(3)) { pkg in
                                    ThreeOneFeaturedCard(package: pkg) {
                                        selectedPackage = pkg
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Packages List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(selectedKind == .all ? "Bản vá & Tiện ích mới" : selectedKind.rawValue)
                            .font(.title3.weight(.bold))
                        Spacer()
                        Text("\(filteredPackages.count) mục")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPackages) { pkg in
                            ThreeOnePackageRow(package: pkg) {
                                selectedPackage = pkg
                            } onToggle: {
                                store.toggleInstall(package: pkg)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .searchable(text: $searchText, placement: .platform(), prompt: "Tìm bản vá, theme, hình nền...")
        .sheet(item: $selectedPackage) { pkg in
            ThreeOnePackageDetailView(package: pkg) {
                store.toggleInstall(package: pkg)
            }
        }
    }
}

// MARK: - Row View
struct ThreeOnePackageRow: View {
    let package: ThreeOnePackage
    let onTap: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "FFD60A").opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: package.iconSystemName)
                    .font(.title3.weight(.bold))
                    .foregroundColor(Color(hex: "DDA200"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(package.name)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("v\(package.version)")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                Text(package.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(package.author)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(package.kind.rawValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(Color(hex: "B8860B"))
                }
            }
            
            Button {
                onToggle()
            } label: {
                Text(package.isInstalled ? "Đã cài" : "Cài đặt")
                    .font(.footnote.weight(.bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(package.isInstalled ? Color.secondary.opacity(0.15) : Color(hex: "FFD60A"))
                    .foregroundColor(package.isInstalled ? .secondary : .black)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Featured Card
struct ThreeOneFeaturedCard: View {
    let package: ThreeOnePackage
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: "FFD60A"))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: package.iconSystemName)
                        .font(.callout.weight(.bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(package.kind.rawValue)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FFD60A").opacity(0.2))
                    .foregroundColor(Color(hex: "8B6914"))
                    .clipShape(Capsule())
            }
            
            Text(package.name)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(package.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            HStack {
                Text("Tác giả: \(package.author)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(Color(hex: "FFD60A"))
            }
        }
        .padding(14)
        .frame(width: 240, height: 160)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Package Detail View
struct ThreeOnePackageDetailView: View {
    @Environment(\.dismiss) var dismiss
    let package: ThreeOnePackage
    let onToggle: () -> Void
    @State private var isApplied: Bool = false
    
    init(package: ThreeOnePackage, onToggle: @escaping () -> Void) {
        self.package = package
        self.onToggle = onToggle
        self._isApplied = State(initialValue: package.isInstalled)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FFD60A").opacity(0.25))
                            .frame(width: 84, height: 84)
                        
                        Image(systemName: package.iconSystemName)
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(Color(hex: "DDA200"))
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 6) {
                        Text(package.name)
                            .font(.title2.weight(.bold))
                        
                        Text("Phát triển bởi \(package.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Text(package.kind.rawValue)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "FFD60A").opacity(0.25))
                                .foregroundColor(Color(hex: "8B6914"))
                                .clipShape(Capsule())
                            
                            Text("Phiên bản \(package.version)")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mô tả chi tiết")
                            .font(.headline.weight(.bold))
                        
                        Text(package.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if let target = package.targetApp {
                            HStack {
                                Text("Ứng dụng mục tiêu:")
                                    .font(.subheadline.weight(.semibold))
                                Text(target)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "DDA200"))
                            }
                            .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Action Button
                    Button {
                        isApplied.toggle()
                        onToggle()
                        HapticManager.shared.impact(.heavy)
                    } label: {
                        HStack {
                            Image(systemName: isApplied ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                            Text(isApplied ? "Đã cài đặt & Áp dụng" : "Cài đặt gói này vào hệ thống")
                        }
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isApplied ? Color.green : Color(hex: "FFD60A"))
                        .foregroundColor(isApplied ? .white : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Chi tiết gói")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") {
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color(hex: "DDA200"))
                }
            }
        }
    }
}
