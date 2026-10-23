//
//  TabEnum.swift
//  feather
//
//  Created by samara on 22.03.2025.
//

import SwiftUI
import NimbleViews

enum TabEnum: String, CaseIterable, Hashable {
    case files
	case sources
	case library
	case settings
	case certificates
	case appstore
    case downloader
    case threeOneOSFive = "3105"
	var title: String {
		switch self {
        case .files:        return .localized("Files")
		case .sources:     	return .localized("Sources")
		case .library: 		return .localized("Library")
		case .settings: 	return .localized("Settings")
		case .certificates:	return .localized("Certificates")
		case .appstore: 	return .localized("App Store")
        case .downloader:   return .localized("Downloads")
        case .threeOneOSFive: return "3105"
		}
	}
	
	var icon: String {
		switch self {
        case .files:        return "folder.fill"
		case .sources: 		return "shippingbox.fill"
		case .library: 		return "tray.full.fill"
		case .settings: 	return "gearshape.fill"
		case .certificates: return "person.badge.shield.checkmark.fill"
		case .appstore: 	return "shippingbox.fill"
        case .downloader:   return "arrow.down.circle.fill"
        case .threeOneOSFive: return "puzzlepiece.extension.fill"
		}
	}
	
	@ViewBuilder
	static func view(for tab: TabEnum) -> some View {
		switch tab {
        case .files: FilesView()
		case .sources: SourcesView()
		case .library: LibraryView()
		case .settings: SettingsView()
		case .certificates: NBNavigationView(.localized("Certificates")) { CertificatesView() }
		case .appstore: AppstoreView()
        case .downloader: DownloaderView()
        case .threeOneOSFive: ThreeOneOSFiveView()
		}
	}
	
	static var defaultTabs: [TabEnum] {
		return [
            .files,
            .library,
            .downloader,
            .appstore,
            .settings,
		]
	}
	
	static var customizableTabs: [TabEnum] {
		return [
			.certificates,
			.threeOneOSFive,
		]
	}
}
