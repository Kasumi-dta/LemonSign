//
//  UpdateManager.swift
//  LemonSign
//
//  Created by Kasumi on 22.10.2026.
//

import UIKit
import Foundation

final class UpdateManager: NSObject {
	static let shared = UpdateManager()

	// Current app constants for this build
	static let currentAppVersion = "1.6.3"
	static let currentAppBuild = 3
	static let currentAppTag = "beta3"

	private let _releasesApiUrl = "https://api.github.com/repos/Kasumi-dta/LemonSign/releases/latest"
	private let _repoJsonUrl = "https://raw.githubusercontent.com/Kasumi-dta/LemonSign/refs/heads/main/repo.json"
	private var _isChecking = false

	private override init() {
		super.init()
	}

	func checkOnLaunch() {
		// Delay slightly so UI hierarchy is completely loaded
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
			self?.checkForUpdates(isManualCheck: false)
		}
	}

	func checkForUpdates(isManualCheck: Bool = false) {
		guard !_isChecking else { return }
		_isChecking = true

		guard let url = URL(string: _releasesApiUrl) else {
			_isChecking = false
			return
		}

		var request = URLRequest(url: url)
		request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
		request.setValue("LemonSign-iOS-Client", forHTTPHeaderField: "User-Agent")
		request.timeoutInterval = 10

		let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			defer { self?._isChecking = false }

			if let data = data,
			   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
			   let tagName = json["tag_name"] as? String {
				
				let releaseName = json["name"] as? String ?? tagName
				let body = json["body"] as? String ?? ""
				
				// Find IPA download URL from assets
				var downloadURLString = "https://github.com/Kasumi-dta/LemonSign/releases/download/\(tagName)/LemonSign.ipa"
				if let assets = json["assets"] as? [[String: Any]] {
					for asset in assets {
						if let name = asset["name"] as? String, name.hasSuffix(".ipa"),
						   let browserURL = asset["browser_download_url"] as? String {
							downloadURLString = browserURL
							break
						}
					}
				}

				DispatchQueue.main.async {
					self?._processRelease(
						tag: tagName,
						name: releaseName,
						body: body,
						downloadURL: downloadURLString,
						isManualCheck: isManualCheck
					)
				}
			} else {
				// Fallback to repo.json check
				self?._checkRepoJsonFallback(isManualCheck: isManualCheck)
			}
		}
		task.resume()
	}

	private func _checkRepoJsonFallback(isManualCheck: Bool) {
		guard let url = URL(string: _repoJsonUrl) else { return }

		URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
			guard let data = data,
				  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				  let apps = json["apps"] as? [[String: Any]],
				  let lemonApp = apps.first(where: { ($0["bundleIdentifier"] as? String)?.contains("lemonsign") == true || ($0["name"] as? String)?.contains("LemonSign") == true })
			else {
				if isManualCheck {
					DispatchQueue.main.async {
						UIAlertController.showAlertWithOk(
							title: .localized("Check for Updates"),
							message: .localized("Unable to check for updates. Please try again later.")
						)
					}
				}
				return
			}

			let version = lemonApp["version"] as? String ?? "1.6.3"
			let downloadURL = lemonApp["downloadURL"] as? String ?? "https://github.com/Kasumi-dta/LemonSign/releases/download/beta3/LemonSign.ipa"
			let desc = lemonApp["localizedDescription"] as? String ?? ""

			DispatchQueue.main.async {
				self?._processRelease(
					tag: version,
					name: "LemonSign v\(version)",
					body: desc,
					downloadURL: downloadURL,
					isManualCheck: isManualCheck
				)
			}
		}.resume()
	}

	private func _isRemoteNewer(remoteTag: String, remoteVersion: String) -> Bool {
		let currentVersionStr = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? Self.currentAppVersion
		let currentTagStr = Self.currentAppTag

		// 1. Check if both are beta tags (e.g. beta2, beta3, beta10)
		let remoteLower = remoteTag.lowercased()
		let currentLower = currentTagStr.lowercased()
		if remoteLower.contains("beta") && currentLower.contains("beta") {
			let remoteBetaNum = Int(remoteLower.replacingOccurrences(of: "beta", with: "")) ?? 1
			let currentBetaNum = Int(currentLower.replacingOccurrences(of: "beta", with: "")) ?? 1
			if remoteBetaNum > currentBetaNum {
				return true
			} else if remoteBetaNum < currentBetaNum {
				return false
			}
		}

		// 2. Semantic version comparison (e.g. 1.6.3 vs 1.6.2)
		let cleanRemote = remoteVersion
			.lowercased()
			.replacingOccurrences(of: "beta", with: "")
			.replacingOccurrences(of: "v", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)
		let cleanCurrent = currentVersionStr
			.lowercased()
			.replacingOccurrences(of: "beta", with: "")
			.replacingOccurrences(of: "v", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)

		let remoteParts = cleanRemote.split(separator: ".").compactMap { Int($0) }
		let currentParts = cleanCurrent.split(separator: ".").compactMap { Int($0) }

		let count = max(remoteParts.count, currentParts.count)
		for i in 0..<count {
			let r = i < remoteParts.count ? remoteParts[i] : 0
			let c = i < currentParts.count ? currentParts[i] : 0
			if r > c { return true }
			if r < c { return false }
		}

		return false
	}

	private func _processRelease(
		tag: String,
		name: String,
		body: String,
		downloadURL: String,
		isManualCheck: Bool
	) {
		let currentVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? Self.currentAppVersion
		let isNewer = _isRemoteNewer(remoteTag: tag, remoteVersion: tag)

		if isNewer {
			let updateTitle = String.localized("New Update Available: %@", arguments: name)
			let cleanBody = body.isEmpty ? "A new version of LemonSign is available with improvements and performance optimizations." : body
			let message = String.localized("A new version of LemonSign is available:\n\n%@\n\nWould you like to download and update now?", arguments: cleanBody)

			let downloadAction = UIAlertAction(title: .localized("Update Now (Download)"), style: .default) { _ in
				if let dlUrl = URL(string: downloadURL) {
					_ = DownloadManager.shared.startDownload(from: dlUrl, id: "LemonSign_Update_\(UUID().uuidString)")
					UIAlertController.showAlertWithOk(
						title: .localized("Downloading Update"),
						message: .localized("LemonSign is downloading the update. You can monitor progress in the Downloads tab to sign and install over.")
					)
				}
			}

			let githubAction = UIAlertAction(title: .localized("View on GitHub"), style: .default) { _ in
				UIApplication.open("https://github.com/Kasumi-dta/LemonSign/releases")
			}

			let cancelAction = UIAlertAction(title: .localized("Later"), style: .cancel, handler: nil)

			UIAlertController.showAlert(
				title: updateTitle,
				message: message,
				actions: [downloadAction, githubAction, cancelAction]
			)
		} else if isManualCheck {
			UIAlertController.showAlertWithOk(
				title: .localized("You're Up to Date"),
				message: String.localized("LemonSign %@ is currently the newest version.", arguments: currentVersion)
			)
		}
	}
}
