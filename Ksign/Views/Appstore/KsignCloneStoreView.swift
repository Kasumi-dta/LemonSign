//
// Adapted from ios-26-clone by Amamamam9777-lang (see ThirdPartyLicenses/ios-26-clone-LICENSE).
// Demonstration-only App Store-style UI; buttons and catalogue use mock data.
// Integrated into LemonSign as a visual demo. Not an Apple-provided component.
//

//
//  LemonStoreAppItem.swift
//  iOS
//
//  Created by Pallav Agarwal on 11/20/25.
//


import SwiftUI
import NimbleExtensions
import Combine

// MARK: - Data Models

struct LemonStoreAppItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let iconColor: Color
    let iconSymbol: String
    let rating: Double
    let reviews: String
    let size: String
    let age: String
    let screenshots: [Color]
    let description: String
}

struct LemonStoreTodayCardItem: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let subtitle: String
    let imageColor: Color
    let overlayPosition: Alignment
}

class LemonStoreStoreData: ObservableObject {
    @Published var featuredApps: [LemonStoreAppItem] = []
    @Published var games: [LemonStoreAppItem] = []
    @Published var todayCards: [LemonStoreTodayCardItem] = []
    
    init() {
        generateMockData()
    }
    
    func generateMockData() {
        featuredApps = [
            LemonStoreAppItem(name: "Procreate", category: "Graphics & Design", iconColor: .purple, iconSymbol: "paintbrush.fill", rating: 4.8, reviews: "24K", size: "450 MB", age: "4+", screenshots: [.purple, .blue, .pink], description: "Sketch, paint, create."),
            LemonStoreAppItem(name: "Linear", category: "Productivity", iconColor: .black, iconSymbol: "checklist", rating: 4.9, reviews: "12K", size: "80 MB", age: "4+", screenshots: [.gray, .black, .white], description: "Issue tracking built for speed."),
            LemonStoreAppItem(name: "Duolingo", category: "Education", iconColor: .green, iconSymbol: "message.fill", rating: 4.7, reviews: "1.2M", size: "120 MB", age: "4+", screenshots: [.green, .orange, .yellow], description: "Learn languages for free."),
            LemonStoreAppItem(name: "Flighty", category: "Travel", iconColor: .orange, iconSymbol: "airplane", rating: 4.8, reviews: "8K", size: "95 MB", age: "4+", screenshots: [.orange, .blue, .black], description: "Live flight tracking."),
            LemonStoreAppItem(name: "Spotify", category: "Music", iconColor: .green, iconSymbol: "music.note", rating: 4.8, reviews: "20M", size: "150 MB", age: "12+", screenshots: [.black, .green, .gray], description: "Music for everyone.")
        ]
        
        games = [
            LemonStoreAppItem(name: "Clash Royale", category: "Strategy", iconColor: .blue, iconSymbol: "shield.fill", rating: 4.6, reviews: "3M", size: "200 MB", age: "9+", screenshots: [.blue, .red, .yellow], description: "Real-time multiplayer battles."),
            LemonStoreAppItem(name: "Genshin Impact", category: "RPG", iconColor: .cyan, iconSymbol: "star.fill", rating: 4.7, reviews: "500K", size: "3.5 GB", age: "12+", screenshots: [.cyan, .purple, .orange], description: "Step into Teyvat."),
            LemonStoreAppItem(name: "Subway Surfers", category: "Action", iconColor: .red, iconSymbol: "figure.run", rating: 4.5, reviews: "1.5M", size: "180 MB", age: "9+", screenshots: [.red, .yellow, .green], description: "Dash as fast as you can!"),
            LemonStoreAppItem(name: "Minecraft", category: "Simulation", iconColor: .green, iconSymbol: "cube.fill", rating: 4.9, reviews: "10M", size: "500 MB", age: "9+", screenshots: [.green, .brown, .blue], description: "Create, explore and survive.")
        ]
        
        todayCards = [
            LemonStoreTodayCardItem(category: "WORLD PREMIERE", title: "The Future of\nMobile Gaming", subtitle: "Experience console quality.", imageColor: .indigo, overlayPosition: .bottomLeading),
            LemonStoreTodayCardItem(category: "APP OF THE DAY", title: "Focus & Flow", subtitle: "Get more done.", imageColor: .orange, overlayPosition: .bottomLeading),
            LemonStoreTodayCardItem(category: "THE BASICS", title: "Edit Photos\nLike a Pro", subtitle: "Top 5 apps for editing.", imageColor: .blue, overlayPosition: .topLeading)
        ]
    }
}

// MARK: - Main Tab View

struct LemonStoreStoreView: View {
    @StateObject private var data = LemonStoreStoreData()
    
    var body: some View {
        TabView {
            LemonStoreTodayView(data: data)
                .tabItem { Label("Today", systemImage: "doc.text.image") }
            
            LemonStoreAppsView(title: "Games", apps: data.games)
                .tabItem { Label("Games", systemImage: "gamecontroller.fill") }
            
            LemonStoreAppsView(title: "Apps", apps: data.featuredApps)
                .tabItem { Label("Apps", systemImage: "square.stack.3d.up.fill") }
            
            Text("Arcade")
                .tabItem { Label("Arcade", systemImage: "arcade.stick") }
            
            LemonStoreSearchView(data: data)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}

// MARK: - 1. Today View

struct LemonStoreTodayView: View {
    @ObservedObject var data: LemonStoreStoreData
    @State private var showAccount = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("THURSDAY, NOVEMBER 20")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Text("Today")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Button(action: { showAccount.toggle() }) {
                            LemonStoreAccountIcon()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Cards
                    ForEach(data.todayCards) { card in
                        LemonStoreTodayCardView(card: card)
                    }
                }
                .padding(.bottom, 20)
            }
            .toolbar(.hidden)
            .sheet(isPresented: $showAccount) {
                LemonStoreAccountView()
            }
        }
    }
}

struct LemonStoreTodayCardView: View {
    let card: LemonStoreTodayCardItem
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: card.overlayPosition) {
                // Background Image Placeholder
                Rectangle()
                    .fill(card.imageColor.gradient)
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.category)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(card.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text(card.subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
            }
        }
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

// MARK: - 2. Apps / Games View (Shared Layout)

struct LemonStoreAppsView: View {
    let title: String
    let apps: [LemonStoreAppItem]
    @State private var showAccount = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Divider()
                    
                    // Horizontal Carousel (Featured)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<3) { _ in
                                LemonStoreFeaturedAppCard()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Sections
                    LemonStoreAppSectionView(title: "Must-Have Apps", apps: apps)
                    LemonStoreAppSectionView(title: "Now Trending", apps: apps.reversed())
                    LemonStoreAppSectionView(title: "Top Paid", apps: apps.shuffled())
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAccount.toggle() }) {
                        LemonStoreAccountIcon()
                    }
                }
            }
            .sheet(isPresented: $showAccount) {
                LemonStoreAccountView()
            }
        }
    }
}

struct LemonStoreAppSectionView: View {
    let title: String
    let apps: [LemonStoreAppItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("See All") {}
                    .font(.body)
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Create grid-like columns of 3 items per slide
                    let chunks = apps.lemonStoreChunked(into: 3)
                    ForEach(0..<chunks.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(chunks[index]) { app in
                                NavigationLink(destination: LemonStoreAppDetailView(app: app)) {
                                    LemonStoreSmallAppRow(app: app)
                                }
                                .buttonStyle(.plain)
                                
                                if app.id != chunks[index].last?.id {
                                    Divider().padding(.leading, 70)
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 40)
                    }
                }
                .padding(.horizontal, 20)
            }
            .compatScrollTargetBehavior()
        }
    }
}

struct LemonStoreSmallAppRow: View {
    let app: LemonStoreAppItem
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(app.iconColor)
                .frame(width: 60, height: 60)
                .overlay(Image(systemName: app.iconSymbol).foregroundStyle(.white).font(.title2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
                Text(app.category)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            LemonStoreGetButton()
        }
        .padding(.vertical, 8)
    }
}

struct LemonStoreFeaturedAppCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NEW UPDATE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)
            
            Text("Clash of Clans")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Major Town Hall update.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ZStack {
                Rectangle()
                    .fill(Color.teal)
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - 3. App Detail View (Product Page)

struct LemonStoreAppDetailView: View {
    let app: LemonStoreAppItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(app.iconColor)
                        .frame(width: 110, height: 110)
                        .overlay(Image(systemName: app.iconSymbol).font(.system(size: 50)).foregroundStyle(.white))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(app.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(app.category)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        HStack {
                            LemonStoreGetButton(width: 75)
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .frame(height: 110)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Divider().padding(.horizontal, 20)
                
                // Stats Row
                HStack(alignment: .top) {
                    LemonStoreStatItem(top: "\(app.rating)", bottom: "★★★★★", caption: "\(app.reviews) Ratings")
                    Divider().frame(height: 30)
                    LemonStoreStatItem(top: "#1", bottom: "Chart", caption: app.category)
                    Divider().frame(height: 30)
                    LemonStoreStatItem(top: app.age, bottom: "Years", caption: "Age")
                }
                .padding(.horizontal, 20)
                
                // What's New
                VStack(alignment: .leading, spacing: 10) {
                    Text("What's New")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Version 4.2.1")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("2d ago")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    
                    Text("Bug fixes and performance improvements. Enjoy the latest update!")
                        .font(.body)
                        .lineLimit(3)
                }
                .padding(.horizontal, 20)
                
                // Screenshots
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(app.screenshots, id: \.self) { color in
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(color.opacity(0.3))
                                .frame(width: 240, height: 440)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        Image(systemName: app.iconSymbol)
                                            .font(.largeTitle)
                                            .foregroundStyle(color)
                                        Spacer()
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text(app.description)
                    Text("Size: \(app.size)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LemonStoreStatItem: View {
    let top: String
    let bottom: String
    let caption: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(top)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.gray)
            Text(bottom)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.gray)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 4. Search View

struct LemonStoreSearchView: View {
    @ObservedObject var data: LemonStoreStoreData
    @State private var searchText = ""
    
    var filteredApps: [LemonStoreAppItem] {
        if searchText.isEmpty { return [] }
        return data.featuredApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) } +
               data.games.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    Section(header: Text("Discover")) {
                        ForEach(["RPG Games", "Video Editors", "Fitness", "Wallpaper"], id: \.self) { item in
                            Button(action: { searchText = item }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text(item)
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    
                    Section(header: Text("Suggested")) {
                        ForEach(data.games.prefix(2)) { app in
                            NavigationLink(destination: LemonStoreAppDetailView(app: app)) {
                                LemonStoreSmallAppRow(app: app)
                            }
                        }
                    }
                } else {
                    ForEach(filteredApps) { app in
                        NavigationLink(destination: LemonStoreAppDetailView(app: app)) {
                            LemonStoreSmallAppRow(app: app)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}

// MARK: - 5. Shared Components

struct LemonStoreGetButton: View {
    var width: CGFloat = 72
    @State private var state: DownloadState = .get
    
    enum DownloadState {
        case get, loading, open
    }
    
    var body: some View {
        Button(action: {
            if state == .get {
                withAnimation { state = .loading }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { state = .open }
                }
            }
        }) {
            ZStack {
                Capsule()
                    .fill(state == .get ? Color(uiColor: .secondarySystemBackground) : (state == .open ? Color.accentColor : .clear))
                
                if state == .get {
                    Text("GET")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                } else if state == .loading {
                    ProgressView()
                } else {
                    Text("OPEN")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: width, height: 28)
        }
        .buttonStyle(.plain)
    }
}

struct LemonStoreAccountIcon: View {
    var body: some View {
        Circle()
            .fill(Color.accentColor.gradient)
            .frame(width: 32, height: 32)
            .overlay(Text("JA").font(.caption).fontWeight(.bold).foregroundStyle(.white))
    }
}

struct LemonStoreAccountView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Circle().fill(Color.accentColor).frame(width: 50, height: 50).overlay(Text("JA").foregroundStyle(.white))
                        VStack(alignment: .leading) {
                            Text("John Appleseed").font(.headline)
                            Text("john.appleseed@icloud.com").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    NavigationLink("Purchased") {}
                    NavigationLink("Subscriptions") {}
                    NavigationLink("Notifications") {}
                }
                
                Section {
                    NavigationLink("Redeem Gift Card or Code") {}
                    NavigationLink("Send Gift Card by Email") {}
                    NavigationLink("Add Funds to Apple ID") {}
                }
                
                Section {
                    Button("Sign Out") { dismiss() }.foregroundStyle(Color.accentColor)
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.bold)
                }
            }
        }
    }
}

// Helper to chunk arrays for the grid layout
extension Array {
    func lemonStoreChunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    LemonStoreStoreView()
}
