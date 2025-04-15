// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class ExtractKit: @unchecked Sendable {
	
	public static let shared: ExtractKit = ExtractKit()
	
	private var fileExtractors: [FileExtractor.Type] = [
		CsvExtractor.self,
		ExcelExtractor.self,
		PdfExtractor.self,
		PowerPointExtractor.self,
		WordExtractor.self,
		ImageExtractor.self,
		EmlxExtractor.self
	]
	
	/// Computed property returning the file extensions of all supported file formats
	public var supportedFileFormats: [String] {
		var fileExtensions: [String] = []
		let allExtractors: [FileExtractor.Type] = self.fileExtractors + [DefaultExtractor.self]
		allExtractors.map({
			$0.fileExtensions
		}).forEach { extensions in
			fileExtensions += extensions
		}
		return fileExtensions.sorted()
	}
	
	/// Function to add a FileExtractor
	public func addFileExtractor(_ fileExtractor: FileExtractor.Type) {
		self.fileExtractors.append(fileExtractor)
	}
	
	/// Function to extract text from common file types and documents
	public func extractText(
        url: URL,
        contentType: ContentType? = nil,
        speed: ExtractionSpeed = .default
    ) async throws -> String {
        if url.isWebURL || contentType == .website {
            // If is web url
            return try await self.extractWebsiteText(url: url)
        } else if url.isFileURL || contentType == .file {
			// Else, if file url
            return try await self.extractFileText(
                url: url,
                speed: speed
            )
		} else {
			// Throw error
			throw ExtractionError.invalidFileFormat
		}
	}
	
	/// Function to extract text from file
	private func extractFileText(
        url: URL,
        speed: ExtractionSpeed = .default
    ) async throws -> String {
		// Check file extension
		let fileExtension: String = url.pathExtension.lowercased()
		// Match extension
		for extractor in self.fileExtractors {
			// If matched
			if extractor.fileExtensions.map({ `extension` in
				`extension`.lowercased()
			}).contains(fileExtension) {
				// Extract text
				let fileExtractor: FileExtractor = extractor.init(
					url: url,
                    speed: speed
				)
				return try await fileExtractor.extractText()
			}
		}
		// If not found, try default
		let defaultExtractor: DefaultExtractor = DefaultExtractor(
			url: url
		)
		do {
			return try await defaultExtractor.extractText()
		} catch {
			throw ExtractionError.invalidFileFormat
		}
	}
	
	/// Function to extract text from website
	private func extractWebsiteText(url: URL) async throws -> String {
		let extractor: WebExtractor = WebsiteExtractor(url: url)
		return try await extractor.extractText()
	}
	
    public enum ContentType {
        case file, website
    }
    
	public enum ExtractionError: LocalizedError {
        
		case invalidURL
		case invalidFileFormat
        
        var localizedDesription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidFileFormat:
                return "Invalid file format"
            }
        }
        
	}
    
}

public enum ExtractionSpeed {
    case `default`
    case fast
}
