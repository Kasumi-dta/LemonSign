//
//  HapticManager.swift
//  LemonSign
//

import UIKit

public final class HapticManager {
	public static let shared = HapticManager()
	
	private init() {}
	
	public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
		DispatchQueue.main.async {
			let generator = UIImpactFeedbackGenerator(style: style)
			generator.prepare()
			generator.impactOccurred()
		}
	}
	
	public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
		DispatchQueue.main.async {
			let generator = UINotificationFeedbackGenerator()
			generator.prepare()
			generator.notificationOccurred(type)
		}
	}
	
	public func selection() {
		DispatchQueue.main.async {
			let generator = UISelectionFeedbackGenerator()
			generator.prepare()
			generator.selectionChanged()
		}
	}
}
