//
//  SettingsDonationCellView.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

import SwiftUI
import NimbleViews

struct SettingsDonationCellView: View {
	var site: String
	
	var body: some View {
		Section {
			VStack(spacing: 14) {
				_brandHeader()
				
				_statusPills()
				
				Button {
					UIApplication.open(site)
				} label: {
					HStack(spacing: 8) {
						Image(systemName: "heart.fill")
							.font(.subheadline)
							.foregroundStyle(.black)
						Text(.localized("Show Your Support"))
							.font(.subheadline.bold())
							.foregroundStyle(.black)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 38)
					.background(Color.accentColor)
					.clipShape(Capsule())
				}
				.buttonStyle(.plain)
			}
			.padding(.vertical, 8)
		}
	}
	
	@ViewBuilder
	private func _brandHeader() -> some View {
		HStack(spacing: 14) {
			if let img = UIImage(named: "lemon_pixel") ?? UIImage(named: "AppIcon") {
				Image(uiImage: img)
					.appIconStyle(size: 60)
			} else {
				Image(systemName: "slider.horizontal.3")
					.font(.title)
					.foregroundStyle(Color.accentColor)
					.frame(width: 60, height: 60)
					.background(Color.accentColor.opacity(0.15))
					.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}
			
			VStack(alignment: .leading, spacing: 3) {
				HStack(spacing: 6) {
					Text("LemonSign")
						.font(.title3.bold())
					
					Text("3105")
						.font(.caption2.bold())
						.foregroundStyle(.black)
						.padding(.horizontal, 6)
						.padding(.vertical, 2)
						.background(Color.accentColor)
						.clipShape(Capsule())
				}
				
				Text("v\(Bundle.main.version) • On-Device Signer")
					.font(.caption)
					.foregroundStyle(.secondary)
				
				Text("Powered by Zsign & Vapor Engine")
					.font(.caption2)
					.foregroundStyle(.tertiary)
			}
			
			Spacer()
		}
	}
	
	@ViewBuilder
	private func _statusPills() -> some View {
		HStack(spacing: 8) {
			_pill(icon: "apple.logo", title: "iOS \(UIDevice.current.systemVersion)")
			_pill(icon: "cpu", title: "Offline Engine")
			_pill(icon: "checkmark.shield", title: "Safe Install")
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	@ViewBuilder
	private func _pill(icon: String, title: String) -> some View {
		HStack(spacing: 4) {
			Image(systemName: icon)
				.font(.system(size: 10, weight: .semibold))
			Text(title)
				.font(.system(size: 11, weight: .medium))
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background(Color(uiColor: .secondarySystemFill))
		.clipShape(Capsule())
		.foregroundStyle(.secondary)
	}
}
