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
	static let currentAppVersion = "2.2"
	static let currentAppBuild = 16
	static let currentAppTag = "v2.2"

	private let _repoJsonUrl = "https://raw.githubusercontent.com/Kasumi-dta/LemonSign/refs/heads/main/repo.json"
	private let _releasesApiUrl = "https://api.github.com/repos/Kasumi-dta/LemonSign/releases?per_page=5"
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

		// Check repo.json first with cache buster
		let timestamp = Int(Date().timeIntervalSince1970)
		guard let url = URL(string: "\(_repoJsonUrl)?t=\(timestamp)") else {
			_isChecking = false
			return
		}

		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		request.timeoutInterval = 10

		let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			if let data = data,
			   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
			   let apps = json["apps"] as? [[String: Any]],
			   let lemonApp = apps.first(where: {
				   ($0["bundleIdentifier"] as? String)?.contains("lemonsign") == true ||
				   ($0["name"] as? String)?.contains("LemonSign") == true
			   }) {
				let remoteVersion = lemonApp["version"] as? String ?? "2.0"
				let remoteBuildStr = (lemonApp["buildVersion"] as? String) ?? "\(lemonApp["buildVersion"] as? Int ?? 14)"
				let remoteBuild = Int(remoteBuildStr) ?? 14
				let downloadURL = lemonApp["downloadURL"] as? String ?? "https://github.com/Kasumi-dta/LemonSign/releases/download/v2.0/LemonSign.ipa"
				let desc = lemonApp["localizedDescription"] as? String ?? ""

				DispatchQueue.main.async {
					self?._isChecking = false
					self?._processRelease(
						version: remoteVersion,
						build: remoteBuild,
						tag: "v\(remoteVersion)",
						name: "LemonSign v\(remoteVersion)",
						body: desc,
						downloadURL: downloadURL,
						isManualCheck: isManualCheck
					)
				}
			} else {
				// Fallback to GitHub releases API
				self?._checkGitHubReleasesFallback(isManualCheck: isManualCheck)
			}
		}
		task.resume()
	}

	private func _checkGitHubReleasesFallback(isManualCheck: Bool) {
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
			   let releases = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
			   let firstRelease = releases.first,
			   let tagName = firstRelease["tag_name"] as? String {

				let releaseName = firstRelease["name"] as? String ?? tagName
				let body = firstRelease["body"] as? String ?? ""

				// Extract semantic version if embedded in release name (e.g. "LemonSign Beta 3 (v1.6.3.1)")
				var parsedVersion = ""
				if let regex = try? NSRegularExpression(pattern: #"v?([0-9]+\.[0-9]+(?:\.[0-9]+)*)"#) {
					let searchString = "\(releaseName) \(tagName)"
					let nsString = searchString as NSString
					if let match = regex.firstMatch(in: searchString, range: NSRange(location: 0, length: nsString.length)) {
						parsedVersion = nsString.substring(with: match.range(at: 1))
					}
				}
				if parsedVersion.isEmpty {
					parsedVersion = tagName
				}

				var downloadURLString = "https://github.com/Kasumi-dta/LemonSign/releases/download/\(tagName)/LemonSign.ipa"
				if let assets = firstRelease["assets"] as? [[String: Any]] {
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
						version: parsedVersion,
						build: 0,
						tag: tagName,
						name: releaseName,
						body: body,
						downloadURL: downloadURLString,
						isManualCheck: isManualCheck
					)
				}
			} else if isManualCheck {
				DispatchQueue.main.async {
					UIAlertController.showAlertWithOk(
						title: .localized("Check for Updates"),
						message: .localized("Unable to check for updates. Please try again later.")
					)
				}
			}
		}
		task.resume()
	}

	private func _isRemoteNewer(remoteVersion: String, remoteBuild: Int, remoteTag: String) -> Bool {
		let currentVersionStr = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? Self.currentAppVersion
		let currentBuildStr = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "\(Self.currentAppBuild)"
		let currentBuild = Int(currentBuildStr) ?? Self.currentAppBuild

		// 1. Semantic version comparison (e.g. 1.6.3.1 vs 1.6.3)
		let cleanRemote = remoteVersion
			.replacingOccurrences(of: "v", with: "", options: .caseInsensitive)
			.replacingOccurrences(of: "beta", with: "", options: .caseInsensitive)
			.trimmingCharacters(in: .whitespacesAndNewlines)
		let cleanCurrent = currentVersionStr
			.replacingOccurrences(of: "v", with: "", options: .caseInsensitive)
			.replacingOccurrences(of: "beta", with: "", options: .caseInsensitive)
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

		// 2. Build number check (if semantic versions are equal)
		if remoteBuild > 0 && currentBuild > 0 {
			if remoteBuild > currentBuild { return true }
			if remoteBuild < currentBuild { return false }
		}

		// 3. Beta tag check (e.g. beta3 vs beta2)
		let remoteLower = remoteTag.lowercased()
		let currentLower = Self.currentAppTag.lowercased()
		if remoteLower.contains("beta") && currentLower.contains("beta") {
			let remoteBetaNum = Int(remoteLower.replacingOccurrences(of: "beta", with: "").trimmingCharacters(in: .letters)) ?? 0
			let currentBetaNum = Int(currentLower.replacingOccurrences(of: "beta", with: "").trimmingCharacters(in: .letters)) ?? 0
			if remoteBetaNum > currentBetaNum { return true }
			if remoteBetaNum < currentBetaNum { return false }
		}

		return false
	}

	private func _processRelease(
		version: String,
		build: Int,
		tag: String,
		name: String,
		body: String,
		downloadURL: String,
		isManualCheck: Bool
	) {
		let currentVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? Self.currentAppVersion
		let isNewer = _isRemoteNewer(remoteVersion: version, remoteBuild: build, remoteTag: tag)

		if isNewer {
			let updateTitle = String.localized("Update Available")
			let message = String.localized("A new version of LemonSign is available (v%@). Would you like to update?", arguments: version)

			let downloadAction = UIAlertAction(title: String.localized("Update Now (Download)"), style: .default) { _ in
				if let dlUrl = URL(string: downloadURL) {
					_ = DownloadManager.shared.startDownload(from: dlUrl, id: "LemonSign_Update_\(UUID().uuidString)")
					UIAlertController.showAlertWithOk(
						title: String.localized("Downloading Update"),
						message: String.localized("LemonSign is downloading the update. You can monitor progress in the Downloads tab to sign and install over.")
					)
				}
			}

			let cancelAction = UIAlertAction(title: String.localized("Later"), style: .cancel, handler: nil)

			UIAlertController.showAlert(
				title: updateTitle,
				message: message,
				actions: [downloadAction, cancelAction]
			)
		} else if isManualCheck {
			let title = String.localized("Check for Updates")
			let message = String.localized("This is the latest version.")
			UIAlertController.showAlertWithOk(
				title: title,
				message: message
			)
		}
	}
}
