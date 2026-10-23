//
//  SSLManager.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import Foundation
import UIKit
import NimbleJSON

final class SSLManager: NSObject {
	static let shared = SSLManager()
	static let sslDidUpdateNotification = Notification.Name("LemonSign.sslDidUpdateNotification")
	
	static let primaryPackUrl = "https://backloop.dev/pack.json"
	static let fallbackPackUrl = "https://raw.githubusercontent.com/Kasumi-dta/LemonSign/refs/heads/main/assets/pack.json"
	
	private let _userDefaults = UserDefaults.standard
	private let _notAfterKey = "Feather.sslNotAfter"
	private let _lastUpdatedKey = "Feather.sslLastUpdated"
	private var _isUpdating = false
	
	private override init() {
		super.init()
	}
	
	var serverDirectory: URL {
		URL.documentsDirectory.appendingPathComponent("App").appendingPathComponent("Server")
	}
	
	var crtURL: URL {
		serverDirectory.appendingPathComponent("server.crt")
	}
	
	var pemURL: URL {
		serverDirectory.appendingPathComponent("server.pem")
	}
	
	var commonNameURL: URL {
		serverDirectory.appendingPathComponent("commonName.txt")
	}
	
	func lastUpdatedDate() -> Date? {
		let time = _userDefaults.double(forKey: _lastUpdatedKey)
		guard time > 0 else { return nil }
		return Date(timeIntervalSince1970: time)
	}
	
	func sslVersion() -> String {
		return _userDefaults.string(forKey: "Feather.sslVersion") ?? "1.0"
	}
	
	func commonNameString() -> String {
		if let str = try? String(contentsOf: commonNameURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines), !str.isEmpty {
			if str.hasPrefix("*.") {
				return "localhost." + str.dropFirst(2)
			}
			return str
		}
		return "localhost.backloop.dev"
	}
	
	func isSSLCertificatePresent() -> Bool {
		let fm = FileManager.default
		return fm.fileExists(atPath: crtURL.path) &&
			   fm.fileExists(atPath: pemURL.path) &&
			   fm.fileExists(atPath: commonNameURL.path)
	}
	
	func sslExpirationDate() -> Date? {
		if let dateStr = _userDefaults.string(forKey: _notAfterKey) {
			let isoFormatter = ISO8601DateFormatter()
			isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
			if let date = isoFormatter.date(from: dateStr) {
				return date
			}
			let standardFormatter = ISO8601DateFormatter()
			if let date = standardFormatter.date(from: dateStr) {
				return date
			}
		}
		
		// Fallback default date for initial bundle cert (Oct 29 2026)
		var comps = DateComponents()
		comps.year = 2026
		comps.month = 10
		comps.day = 29
		comps.hour = 10
		comps.minute = 20
		comps.timeZone = TimeZone(secondsFromGMT: 0)
		return Calendar.current.date(from: comps)
	}
	
	func isExpiredOrExpiringSoon(daysThreshold: Int = 14) -> Bool {
		guard isSSLCertificatePresent() else {
			return true
		}
		
		guard let expDate = sslExpirationDate() else {
			return true
		}
		
		let secondsInDay: TimeInterval = 86400
		let thresholdInterval = TimeInterval(daysThreshold) * secondsInDay
		let now = Date()
		
		// If already past expiration date or expires within threshold
		if expDate <= now || expDate.timeIntervalSince(now) < thresholdInterval {
			return true
		}
		
		return false
	}
	
	func autoCheckAndUpdateSSL(force: Bool = false, completion: ((Bool) -> Void)? = nil) {
		guard !_isUpdating else {
			completion?(false)
			return
		}
		
		if !force && !isExpiredOrExpiringSoon() {
			completion?(true)
			return
		}
		
		_isUpdating = true
		print("[SSLManager] Checking and auto-updating SSL certificates (force: \(force))...")
		
		_downloadCertificates(from: Self.primaryPackUrl) { [weak self] success in
			guard let self = self else { return }
			if success {
				self._isUpdating = false
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: Self.sslDidUpdateNotification, object: nil)
					completion?(true)
				}
			} else {
				// Try fallback URL
				print("[SSLManager] Primary pack URL failed, attempting fallback...")
				self._downloadCertificates(from: Self.fallbackPackUrl) { fallbackSuccess in
					self._isUpdating = false
					DispatchQueue.main.async {
						if fallbackSuccess {
							NotificationCenter.default.post(name: Self.sslDidUpdateNotification, object: nil)
						}
						completion?(fallbackSuccess)
					}
				}
			}
		}
	}
	
	private func _downloadCertificates(from urlString: String, completion: @escaping (Bool) -> Void) {
		NBFetchService().fetch(from: urlString) { [weak self] (result: Result<ServerPackModel, Error>) in
			guard let self = self else {
				completion(false)
				return
			}
			
			switch result {
			case .success(let pack):
				do {
					let fm = FileManager.default
					try fm.createDirectoryIfNeeded(at: self.serverDirectory)
					
					let rawCommonName = pack.info.domains?.commonName ?? "*.backloop.dev"
					let commonName = rawCommonName.hasPrefix("*.") ? ("localhost." + rawCommonName.dropFirst(2)) : (rawCommonName == "*" ? "localhost.backloop.dev" : rawCommonName)
					
					try pack.key.write(to: self.pemURL, atomically: true, encoding: .utf8)
					try pack.cert.write(to: self.crtURL, atomically: true, encoding: .utf8)
					try commonName.write(to: self.commonNameURL, atomically: true, encoding: .utf8)
					
					if let notAfter = pack.info.notAfter {
						self._userDefaults.set(notAfter, forKey: self._notAfterKey)
					}
					if let ver = pack.version?.num {
						self._userDefaults.set(ver, forKey: "Feather.sslVersion")
					} else {
						self._userDefaults.set("1.0", forKey: "Feather.sslVersion")
					}
					self._userDefaults.set(Date().timeIntervalSince1970, forKey: self._lastUpdatedKey)
					
					print("[SSLManager] Successfully updated SSL certificates from \(urlString). CommonName: \(commonName)")
					completion(true)
				} catch {
					print("[SSLManager] Failed to write SSL files to disk: \(error)")
					completion(false)
				}
			case .failure(let error):
				print("[SSLManager] Failed to fetch pack.json from \(urlString): \(error)")
				completion(false)
			}
		}
	}
}
