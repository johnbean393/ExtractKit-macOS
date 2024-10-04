//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation
import BrowserKit
import SwiftSoup

public class WebsiteExtractor: WebExtractor {
	
	public required init(url: URL) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = []
	
	public func extractText() async throws -> String {
		// Get website content
		let urlRequest = URLRequest(url: self.url)
		var htmlString = try await URLSession.shared.data(for: urlRequest).0.toString()
		// If possible, clean up HTML string
		if let document: Document = try? SwiftSoup.parse(htmlString) {
			try document.select("meta").remove()
			try document.select("style").remove()
			try document.select("script").remove()
			htmlString = try document.outerHtml()
		}
		// Init TurndownJS object
		let turndown = await _TurndownJS()
		// Convert to markdown
		let markdown = try await turndown.convert(htmlString: htmlString)
		return markdown
	}
	
}
