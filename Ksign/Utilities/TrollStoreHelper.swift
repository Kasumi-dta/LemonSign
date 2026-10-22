//
//  TrollStoreHelper.swift
//  LemonSign
//

import UIKit

public enum TrollStoreHelper {
	public static var isTrollStoreAvailable: Bool {
		if let magnifierUrl = URL(string: "apple-magnifier://"), UIApplication.shared.canOpenURL(magnifierUrl) {
			return true
		}
		if let trollstoreUrl = URL(string: "trollstore://"), UIApplication.shared.canOpenURL(trollstoreUrl) {
			return true
		}
		let knownPaths = [
			"/Applications/TrollStore.app",
			"/var/jb/Applications/TrollStore.app",
			"/var/containers/Bundle/Application/TrollStore.app"
		]
		return knownPaths.contains { FileManager.default.fileExists(atPath: $0) }
	}

	@discardableResult
	public static func install(fileUrl: URL) -> Bool {
		let escapedPath = fileUrl.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fileUrl.path
		if let url = URL(string: "apple-magnifier://install?url=\(escapedPath)") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url)
				return true
			}
		}
		if let url = URL(string: "trollstore://install?url=\(escapedPath)") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url)
				return true
			}
		}
		// Fallback direct open
		if let url = URL(string: "apple-magnifier://install?url=\(escapedPath)") {
			UIApplication.shared.open(url)
			return true
		}
		return false
	}
}
