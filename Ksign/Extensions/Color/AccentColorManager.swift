//
//  AccentColorManager.swift
//  Ksign
//
//  Created by Nagata Asami on 6/30/25.
//

import SwiftUI
import UIKit

// MARK: - Accent Color Manager
class AccentColorManager: ObservableObject {
    static let shared = AccentColorManager()
    
    var currentAccentColor: Color {
        Color(red: 0xFF/255, green: 0xD6/255, blue: 0x0A/255)
    }
    
    var currentUIColor: UIColor {
        UIColor(red: 0xFF/255, green: 0xD6/255, blue: 0x0A/255, alpha: 1.0)
    }
    
    /// Updates the global app tint color
    func updateGlobalTintColor() {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { window in
                    window.tintColor = self.currentUIColor
                }
        }
    }
} 