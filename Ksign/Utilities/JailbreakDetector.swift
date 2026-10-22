//
//  JailbreakDetector.swift
//  LemonSign
//
//  Created for LemonSign on 22.10.2026.
//

import Foundation
import UIKit

enum JailbreakDetector {
    /// Returns true if the device is currently jailbroken (supports both rootful and modern rootless jailbreaks)
    static var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // 1. Common jailbreak file and directory paths (rootful & modern rootless like Dopamine / Palera1n)
        let jbPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/var/jb",
            "/var/binpack",
            "/var/lib/apt",
            "/var/lib/cydia",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/etc/apt",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/libexec/cydia",
            "/var/checkra1n.dmg",
            "/bin/bash"
        ]
        
        for path in jbPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // 2. Sandbox escape test: try writing outside sandbox
        let testPath = "/private/lemon_jb_test_\(UUID().uuidString).txt"
        do {
            try "jb".write(toFile: testPath, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // Expected to fail on stock non-jailbroken iOS
        }
        
        // 3. Check popular package manager URL schemes
        if let cydiaUrl = URL(string: "cydia://"), UIApplication.shared.canOpenURL(cydiaUrl) {
            return true
        }
        if let sileoUrl = URL(string: "sileo://"), UIApplication.shared.canOpenURL(sileoUrl) {
            return true
        }
        if let zebraUrl = URL(string: "zbra://"), UIApplication.shared.canOpenURL(zebraUrl) {
            return true
        }
        
        return false
        #endif
    }
}
