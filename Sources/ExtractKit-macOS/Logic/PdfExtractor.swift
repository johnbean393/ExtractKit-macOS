//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation
import PDFKit

public class PdfExtractor: FileExtractor {
	
	public required init(url: URL) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"pdf"
	]
	
	public func extractText() async throws -> String {
		// Init pdf document
		guard let pdf = PDFDocument(url: url) else {
			throw PdfError.failedToReadFile
		}
		let pageCount = pdf.pageCount
		let documentContent = NSMutableAttributedString()
		// Extract contents of each page
		for pageIndex in 0..<pageCount {
			// Get text content
			guard let page: PDFPage = pdf.page(at: pageIndex) else {
				continue
			}
			guard let pageContent: NSAttributedString = page.attributedString else {
				continue
			}
			// Check if text is reversed
			if pageContent.string.components(separatedBy: " ,").count >= 3 || pageContent.string.components(separatedBy: " .").count >= 5 {
				// If reversed, add reversed string
				documentContent.append(
					NSAttributedString(string: pageContent.string.reduce("") { "\($1)" + $0 } )
				)
			} else {
				// If not reversed, add normal string
				documentContent.append(pageContent)
			}
			// Add new line
			documentContent.append(NSAttributedString(string: "\n"))
		}
		// Return text
		return documentContent.string
	}
	
	public enum PdfError: Error {
		case failedToReadFile
	}
	
}
