//
//  Server.swift
//  feather
//
//  Created by samara on 22.08.2024.
//  Copyright © 2024 Lakr Aream. All Rights Reserved.
//  ORIGINALLY LICENSED UNDER GPL-3.0, MODIFIED FOR USE FOR FEATHER
//

import Foundation
import Vapor
import NIOSSL
import NIOTLS
import SwiftUI
import IDeviceSwift

// MARK: - Class
class ServerInstaller: Identifiable, ObservableObject {
	let id = UUID()
	let port = Int.random(in: 4000...8000)
	private var _needsShutdown = false
	
	var packageUrl: URL?
	var app: AppInfoPresentable
	@ObservedObject var viewModel: InstallerStatusViewModel
	private var _server: Application

	init(app: AppInfoPresentable, viewModel: InstallerStatusViewModel) throws {
		self.app = app
		self.viewModel = viewModel
		self._server = try Self.setupApp(port: port)
		
		try _configureRoutes()
		try _server.server.start()
		_needsShutdown = true
	}
	
	deinit {
		_shutdownServer()
	}
		
	private func _configureRoutes() throws {
		_server.get("*") { [weak self] req in
			guard let self else { return Response(status: .badGateway) }
			switch req.url.path {
			case plistEndpoint.path:
				self._updateStatus(.sendingManifest)
				return Response(status: .ok, version: req.version, headers: [
					"Content-Type": "text/xml",
				], body: .init(data: installManifestData))
			case displayImageSmallEndpoint.path:
				return Response(status: .ok, version: req.version, headers: [
					"Content-Type": "image/png",
				], body: .init(data: displayImageSmallData))
			case displayImageLargeEndpoint.path:
				return Response(status: .ok, version: req.version, headers: [
					"Content-Type": "image/png",
				], body: .init(data: displayImageLargeData))
			case payloadEndpoint.path:
				guard let packageUrl = packageUrl else {
					return Response(status: .notFound)
				}
				
				self._updateStatus(.sendingPayload)
				
				let res = req.fileio.streamFile(
					at: packageUrl.path,
					chunkSize: 1024 * 1024
				) { result in
                    switch result {
                    case .success:
                        self._updateStatus(.installing)
                    case .failure(let error):
                        self._updateStatus(.broken(error))
                    }
				}
				res.headers.replaceOrAdd(name: .contentType, value: "application/octet-stream")
				res.headers.replaceOrAdd(name: "Accept-Ranges", value: "bytes")
				res.headers.replaceOrAdd(name: .cacheControl, value: "no-cache, no-store, must-revalidate")
				res.headers.replaceOrAdd(name: "Connection", value: "keep-alive")
				return res
			case "/install":
				var headers = HTTPHeaders()
				headers.add(name: .contentType, value: "text/html")
				return Response(status: .ok, headers: headers, body: .init(string: self.html))
			default:
				return Response(status: .notFound)
			}
		}
	}
	
	private func _shutdownServer() {
		guard _needsShutdown else { return }
		
		_needsShutdown = false
		_server.server.shutdown()
		_server.shutdown()
	}
	
    private func _updateStatus(_ newStatus: InstallerStatusViewModel.InstallerStatus) {
		DispatchQueue.main.async {
			self.viewModel.status = newStatus
		}
	}
		
	func restartAsFullyLocal() throws {
		_shutdownServer()
		Self.setServerMethod(0)
		self._server = try Self.setupApp(port: port)
		try _configureRoutes()
		try _server.server.start()
		_needsShutdown = true
		print("[ServerInstaller] Successfully restarted as Fully Local (HTTPS) on port \(port)")
	}

	static var isHighIOS: Bool {
		ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17
	}
		
	static func getServerMethod() -> Int {
		if isHighIOS {
			return 0
		}
		return UserDefaults.standard.integer(forKey: "Feather.serverMethod")
	}
	
	static func getIPFix() -> Bool {
		UserDefaults.standard.bool(forKey: "Feather.ipFix")
	}
	
	static func setServerMethod(_ method: Int) {
		UserDefaults.standard.set(method, forKey: "Feather.serverMethod")
	}
	
	static func setIPFix(_ enabled: Bool) {
		UserDefaults.standard.set(enabled, forKey: "Feather.ipFix")
	}
	
	static let serverPackUrl = "https://backloop.dev/pack.json"
	
	@discardableResult
	static func switchServerMethod() -> Int {
		let current = getServerMethod()
		let next = (current == 0 ? 1 : 0)
		setServerMethod(next)
		return next
	}
	
	static func serverMethodDisplayName(_ method: Int) -> String {
		method == 1 ? "Bán cục bộ (Semi Local)" : "Cục bộ hoàn toàn (Fully Local)"
	}
}
