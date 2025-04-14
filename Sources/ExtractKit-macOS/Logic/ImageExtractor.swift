//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation
import Vision
import AppKit

public class ImageExtractor: FileExtractor {
	
	public required init(
        url: URL,
        speed: ExtractionSpeed = .default
    ) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"png",
		"jpg",
		"jpeg",
		"tiff",
		"webp",
		"heic",
		"bmp"
	]
	
    public func extractText() async throws -> String {
        // Convert to NSImage
        let nsImage: NSImage = NSImage(byReferencing: url)
        // Extract text
        return try await Self.extractNSImage(nsImage: nsImage)
    }
    
    /// Function to extract text from an NSImage
    public static func extractNSImage(
        nsImage: NSImage
    ) async throws -> String {
        guard let imgRef = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ImageError.failedToReadFile
        }
        // Build the request handler and perform the request
        var resultText: String = ""
        let request = VNRecognizeTextRequest { (request, error) in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            // Take the most likely result for each chunk, then send them all the stdout
            let chunks: [String] = observations.map {
                $0.topCandidates(1).first?.string ?? ""
            }
            resultText = chunks.joined(separator: "\n")
        }
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.usesLanguageCorrection = true
        // Use different requests for different macOS version
        if #available(macOS 13.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        } else {
            request.revision = VNRecognizeTextRequestRevision2
        }
        // Determine and use language
        let langStrs: [String] = [
            "en", "zh", "hi", "es", "fr", "ar",
            "bn", "ru", "pt", "ur", "id", "de",
            "ja", "tr", "vi", "th", "la"
        ]
        let langs: [Locale.Language] = langStrs.map({
            Locale.Language(identifier: $0)
        })
        let uniqueLangs: [Locale.Language] = (langs + Locale.Language.systemLanguages).unique(
            { $0.minimalIdentifier == $1.minimalIdentifier }
        )
        request.recognitionLanguages = uniqueLangs.map {
            $0.minimalIdentifier
        }
        try VNImageRequestHandler(cgImage: imgRef, options: [:]).perform([request])
        return resultText
    }
	
	public enum ImageError: Error {
        
		case failedToReadFile
        
        var localizedDescription: String {
            switch self {
                case .failedToReadFile:
                    return "Failed to read file"
            }
        }
        
	}
	
}
