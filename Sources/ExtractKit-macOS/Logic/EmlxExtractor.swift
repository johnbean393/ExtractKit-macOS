//
//  EmlxExtractor.swift
//  ExtractKit-macOS
//
//  Created by John Bean on 3/17/25.
//

import Foundation
import BrowserKit
import SwiftSoup

public class EmlxExtractor: FileExtractor {
	
	public required init(url: URL) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"emlx"
	]
	
	public func extractText() async throws -> String {
		// Get HTML text in file
		var htmlString: String = try String(contentsOf: url, encoding: .utf8)
		// If possible, clean up HTML string
		let document: Document = try SwiftSoup.parse(htmlString)
		try document.select("meta").remove()
		try document.select("style").remove()
		try document.select("script").remove()
		htmlString = try document.outerHtml()
		// Init TurndownJS object
		let turndown = await _TurndownJS()
		// Convert to markdown
		let markdown: String = try await turndown.convert(htmlString: htmlString)
		// Drop weird suffix
		var lines: [String] = markdown.split(separator: "\n").map({ String($0) })
		let slashThresholdPercent: Float = 0.15
		lines = lines.map { line in
			let slashCount: Int = line.components(separatedBy: "/").count - 1
			let slashPercent: Float = Float(slashCount) / Float(line.count)
			if slashPercent > slashThresholdPercent {
				return nil
			}
			return line
		}.compactMap({ $0 })
		return lines.joined(separator: "\n")
	}
	
}

