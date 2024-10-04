//
//  DocxExtractor.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/2/24.
//

import AppKit
import Foundation

public class WordExtractor: FileExtractor {
	
	public required init(url: URL) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"doc",
		"docx"
	]
	
	public func extractText() async throws -> String {
		let fileData: NSData =  try NSData(contentsOf: url)
		let extractedText: NSAttributedString = try NSAttributedString(
			data: fileData as Data,
			options: [
				.documentType: NSAttributedString.DocumentType.officeOpenXML,
				.characterEncoding: String.Encoding.utf8.rawValue
			],
			documentAttributes: nil
		)
		return extractedText.string
	}
	
}
