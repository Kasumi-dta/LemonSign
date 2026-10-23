//
//  ThreeOneOSFiveSupport.swift
//  LemonSign
//
//  Created by Kasumi on 23.10.2026.
//

import Foundation
import UIKit

enum ThreeOneOSFiveSupport {
    static var operatingSystemVersion: OperatingSystemVersion {
        ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static var majorVersion: Int {
        operatingSystemVersion.majorVersion
    }
    
    static var minorVersion: Int {
        operatingSystemVersion.minorVersion
    }
    
    static var patchVersion: Int {
        operatingSystemVersion.patchVersion
    }
    
    static var versionString: String {
        "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
    
    /// Checks device compatibility based on 3105 SupportPolicy
    static var isSupported: Bool {
        // iOS 17: 17.0 through 17.7
        if majorVersion == 17 {
            return minorVersion <= 7
        }
        
        // iOS 18: 18.0 through 18.7.1
        if majorVersion == 18 {
            return minorVersion < 7 || (minorVersion == 7 && patchVersion <= 1)
        }
        
        // iOS 26: 26.0 through 26.6.1
        if majorVersion == 26 {
            return minorVersion < 6 || (minorVersion == 6 && patchVersion <= 1)
        }
        
        // iOS 27 Developer Betas 1-4
        if majorVersion == 27 {
            return true
        }
        
        return false
    }
    
    static var compatibilityMessage: String {
        if isSupported {
            return "Thiết bị tương thích (iOS \(versionString))"
        } else {
            return "Thiết bị chưa hỗ trợ (iOS \(versionString)) - Yêu cầu iOS 17.0 - 17.7 hoặc 18.0 - 18.7.1"
        }
    }
    
    static var supportedRangesDescription: String {
        """
        - iOS 17: 17.0 đến 17.7
        - iOS 18: 18.0 đến 18.7.1
        - iOS 26: 26.0 đến 26.6.1
        - iOS 27 Beta 1 đến Beta 4
        """
    }
}
