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
							message: .localized("Không thể kết nối đến máy chủ cập nhật. Vui lòng thử lại sau.")
						)
					}
				}
				return
			}

			let version = lemonApp["version"] as? String ?? "1.6.2"
			let downloadURL = lemonApp["downloadURL"] as? String ?? "https://github.com/Kasumi-dta/LemonSign/releases/download/beta2/LemonSign.ipa"
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

	private func _processRelease(
		tag: String,
		name: String,
		body: String,
		downloadURL: String,
		isManualCheck: Bool
	) {
		let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.6.1"
		let currentTag = UserDefaults.standard.string(forKey: "lemonsign.appTag") ?? "beta"

		let isNewer: Bool
		let cleanTag = tag.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
		let cleanCurrent = currentVersion.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))

		if cleanTag.compare(cleanCurrent, options: .numeric) == .orderedDescending {
			isNewer = true
		} else if tag.lowercased() == "beta2" && currentTag.lowercased() != "beta2" {
			isNewer = true
		} else if isManualCheck && tag != currentTag {
			isNewer = true
		} else {
			isNewer = false
		}

		if isNewer {
			let updateTitle = "🎉 Bản cập nhật mới: \(name)"
			let cleanBody = body.isEmpty ? "Đã có bản cập nhật LemonSign mới nhất với các cải tiến và sửa lỗi." : body
			let message = "\(cleanBody)\n\nBạn có muốn tải về và cập nhật ngay không?"

			let downloadAction = UIAlertAction(title: "Cập nhật ngay (Tải về)", style: .default) { _ in
				if let dlUrl = URL(string: downloadURL) {
					_ = DownloadManager.shared.startDownload(from: dlUrl, id: "LemonSign_Update_\(UUID().uuidString)")
					UIAlertController.showAlertWithOk(
						title: "Đang tải bản cập nhật",
						message: "LemonSign đang tải bản cập nhật về máy. Bạn có thể theo dõi tiến trình tải trong thanh thông báo hoặc mục Tải về để ký và cài đặt đè."
					)
				}
			}

			let githubAction = UIAlertAction(title: "Xem trên GitHub", style: .default) { _ in
				UIApplication.open("https://github.com/Kasumi-dta/LemonSign/releases")
			}

			let cancelAction = UIAlertAction(title: "Để sau", style: .cancel, handler: nil)

			UIAlertController.showAlert(
				title: updateTitle,
				message: message,
				actions: [downloadAction, githubAction, cancelAction]
			)
		} else if isManualCheck {
			UIAlertController.showAlertWithOk(
				title: "LemonSign đã là bản mới nhất",
				message: "Bạn đang sử dụng phiên bản \(currentVersion) mới nhất với công nghệ tối ưu LemonTurbo."
			)
		}
	}
}
