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
	
	public required init(url: URL) {
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
		var resultText: String = ""
		// Build the request handler and perform the request
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
		guard let imgRef = NSImage(byReferencing: url).cgImage(forProposedRect: nil, context: nil, hints: nil) else {
			throw ImageError.failedToReadFile
		}
		try VNImageRequestHandler(cgImage: imgRef, options: [:]).perform([request])
		return resultText
	}
	
	public enum ImageError: Error {
		case failedToReadFile
	}
	
}
