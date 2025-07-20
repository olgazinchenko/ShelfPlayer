//
//  File.swift
//
//
//  Created by Rasmus Krämer on 23.01.24.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public extension ShelfPlayerKit {
    static let groupContainer = "group.io.rfk.shelfplayer"
    static let shelfPlayerFolder = "ShelfPlayer"
    static let downloadFolderV2 = "DownloadV2"
    static let downloadsFolder = "Downloads"
    
    static nonisolated(unsafe) var enableCentralized = true
    
    static let clientBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    static let clientVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    
    #if canImport(UIKit)
    @MainActor
    static let osVersion = UIDevice.current.systemVersion
    #endif
    
    static let model: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let bytes = withUnsafeBytes(of: systemInfo.machine.self) { [UInt8]($0) }
        let firstWhitespaceIndex = bytes.firstIndex(of: 0x00) ?? bytes.endIndex
        
        return String(decoding: bytes[0..<firstWhitespaceIndex], as: UTF8.self)
    }()
    
    static var suite: UserDefaults {
        enableCentralized ? UserDefaults(suiteName: groupContainer)! : UserDefaults.standard
    }
    
    private static nonisolated(unsafe) var _clientID: String? = nil
    static var clientID: String {
        if let clientID = suite.string(forKey: "clientId") {
            _clientID = clientID
        } else {
            _clientID = String(length: 100)
            suite.set(_clientID, forKey: "clientId")
        }
        
        return _clientID!
    }
    
    static let downloadDirectoryURL: URL = {
        let baseURL: URL
        
        if enableCentralized,
           let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupContainer) {
            baseURL = groupURL
                .appending(path: shelfPlayerFolder, directoryHint: .isDirectory)
                .appending(path: downloadFolderV2, directoryHint: .isDirectory)
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                                 in: .userDomainMask)[0]
                .appending(path: shelfPlayerFolder, directoryHint: .isDirectory)
                .appending(path: downloadsFolder, directoryHint: .isDirectory)
            baseURL = appSupport
        }
        
        do {
            try FileManager.default.createDirectory(at: baseURL,
                                                    withIntermediateDirectories: true)
        } catch {
            assertionFailure("⚠️ Couldn’t create download directory: \(error)")
        }
        
        return baseURL
    }()
}
