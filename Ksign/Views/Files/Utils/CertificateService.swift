//
//  CertificateService.swift
//  Ksign
//
//  Created by Nagata Asami on 5/22/25.
//

import Foundation
import UniformTypeIdentifiers

final class CertificateService {
    
    // MARK: - Shared Instance
    static let shared = CertificateService()
    private init() {}
    
    // MARK: - Import Result
    enum ImportResult {
        case success(String)
        case failure(ImportError)
    }
    
    enum ImportError: LocalizedError {
        case invalidFile
        case invalidFileFormat
        case missingProvisionData
        case missingCertificateData
        case invalidPassword
        case multipleProvisionFiles
        case noProvisionFile
        case importFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidFile:
                return "Invalid or inaccessible file"
            case .invalidFileFormat:
                return "Invalid file format"
            case .missingProvisionData:
                return "Missing provisioning profile data"
            case .missingCertificateData:
                return "Missing certificate data"
            case .invalidPassword:
                return "Invalid certificate password"
            case .multipleProvisionFiles:
                return "Multiple .mobileprovision files found. Please import certificate using the Settings > Certificates section."
            case .noProvisionFile:
                return "No .mobileprovision file found in the same directory"
            case .importFailed(let message):
                return "Failed to import certificate: \(message)"
            }
        }
    }
    
    // MARK: - Public Methods
    
    private func makeFileItem(from url: URL) throws -> FileItem {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .isDirectoryKey])
        return FileItem(
            name: url.lastPathComponent,
            url: url,
            size: Int64(resourceValues.fileSize ?? 0),
            creationDate: resourceValues.creationDate,
            isDirectory: resourceValues.isDirectory ?? false
        )
    }
    
    /// Finds the best matching .mobileprovision file in the same directory as the given .p12
    func findProvisionFile(near p12File: FileItem) -> Result<FileItem, ImportError> {
        guard p12File.isP12Certificate else { return .failure(.invalidFile) }
        let directory = p12File.url.deletingLastPathComponent()
        let fileManager = FileManager.default
        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .isDirectoryKey]
            )
            let provisionFiles = directoryContents.filter { url in
                url.pathExtension.lowercased() == "mobileprovision"
            }
            if provisionFiles.isEmpty { return .failure(.noProvisionFile) }
            
            let p12Stem = p12File.url.deletingPathExtension().lastPathComponent.lowercased()
            
            // 1. Exact base name match (case-insensitive)
            if let exactMatch = provisionFiles.first(where: {
                $0.deletingPathExtension().lastPathComponent.lowercased() == p12Stem
            }) {
                return .success(try makeFileItem(from: exactMatch))
            }
            
            // 2. Contains / partial match (e.g., Cert_dev.p12 and Cert_dev.mobileprovision)
            if let partialMatch = provisionFiles.first(where: {
                let provStem = $0.deletingPathExtension().lastPathComponent.lowercased()
                return p12Stem.contains(provStem) || provStem.contains(p12Stem)
            }) {
                return .success(try makeFileItem(from: partialMatch))
            }
            
            // 3. Single provision file in the directory
            if provisionFiles.count == 1 {
                return .success(try makeFileItem(from: provisionFiles[0]))
            }
            
            // 4. Multiple provision files exist: pick the newest modified one
            let sortedProvisions = provisionFiles.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                return date1 > date2
            }
            if let newest = sortedProvisions.first {
                return .success(try makeFileItem(from: newest))
            }
            
            return .failure(.noProvisionFile)
        } catch {
            return .failure(.importFailed(error.localizedDescription))
        }
    }
    
    /// Finds the best matching .p12 file in the same directory as the given .mobileprovision
    func findP12File(near provisionFile: FileItem) -> Result<FileItem, ImportError> {
        guard provisionFile.isMobileProvision else { return .failure(.invalidFile) }
        let directory = provisionFile.url.deletingLastPathComponent()
        let fileManager = FileManager.default
        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .isDirectoryKey]
            )
            let p12Files = directoryContents.filter { url in
                url.pathExtension.lowercased() == "p12"
            }
            if p12Files.isEmpty { return .failure(.invalidFile) }
            
            let provStem = provisionFile.url.deletingPathExtension().lastPathComponent.lowercased()
            
            // 1. Exact base name match (case-insensitive)
            if let exactMatch = p12Files.first(where: {
                $0.deletingPathExtension().lastPathComponent.lowercased() == provStem
            }) {
                return .success(try makeFileItem(from: exactMatch))
            }
            
            // 2. Contains / partial match
            if let partialMatch = p12Files.first(where: {
                let p12Stem = $0.deletingPathExtension().lastPathComponent.lowercased()
                return provStem.contains(p12Stem) || p12Stem.contains(provStem)
            }) {
                return .success(try makeFileItem(from: partialMatch))
            }
            
            // 3. Single p12 file in directory
            if p12Files.count == 1 {
                return .success(try makeFileItem(from: p12Files[0]))
            }
            
            // 4. Multiple p12 files exist: pick the newest modified one
            let sortedP12s = p12Files.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                return date1 > date2
            }
            if let newest = sortedP12s.first {
                return .success(try makeFileItem(from: newest))
            }
            
            return .failure(.invalidFile)
        } catch {
            return .failure(.importFailed(error.localizedDescription))
        }
    }
    
    func importP12Certificate(p12File: FileItem, provisionFile: FileItem, password: String, completion: @escaping (ImportResult) -> Void) {
        guard FR.checkPasswordForCertificate(
            for: p12File.url,
            with: password,
            using: provisionFile.url
        ) else {
            completion(.failure(.invalidPassword))
            return
        }
        
        FR.handleCertificateFiles(
            p12URL: p12File.url,
            provisionURL: provisionFile.url,
            p12Password: password,
            certificateName: p12File.name.replacingOccurrences(of: ".p12", with: "")
        ) { error in
            if let error = error {
                completion(.failure(.importFailed(error.localizedDescription)))
            } else {
                completion(.success("Certificate imported successfully"))
            }
        }
    }
}

// MARK: - Extensions

extension UTType {
    static var ksign: UTType {
        UTType(exportedAs: "com.kasumidta.lemonsign.cert")
    }
} 
