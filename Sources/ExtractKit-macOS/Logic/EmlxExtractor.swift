//
//  EmlxExtractor.swift
//  ExtractKit-macOS
//
//  Created by John Bean on 3/17/25.
//

import Foundation
import SwiftSoup

public class EmlxExtractor: FileExtractor {
	
	public required init(
        url: URL,
        speed: ExtractionSpeed = .default
    ) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"emlx"
	]
	
    public func extractText() async throws -> String {
        // Get HTML text in file
        let htmlString: String = try String(contentsOf: url, encoding: .utf8)
        // Parse and clean up HTML
        let document: Document = try SwiftSoup.parse(htmlString)
        // Remove non-content elements
        try document.select("script").remove()
        try document.select("style").remove()
        try document.select("meta").remove()
        try document.select("link").remove()
        try document.select("noscript").remove()
        // Remove navigation and structural elements
        try document.select("nav").remove()
        try document.select("header").remove()
        try document.select("footer").remove()
        try document.select("aside").remove()
        // Remove interactive elements
        try document.select("form").remove()
        try document.select("button").remove()
        try document.select("input").remove()
        try document.select("select").remove()
        try document.select("textarea").remove()
        // Remove embedded content
        try document.select("iframe").remove()
        try document.select("embed").remove()
        try document.select("object").remove()
        try document.select("svg").remove()
        // Remove common ad and tracking containers
        try document.select("[class*='ad-']").remove()
        try document.select("[class*='ads-']").remove()
        try document.select("[id*='ad-']").remove()
        try document.select("[id*='ads-']").remove()
        try document.select("[class*='advertisement']").remove()
        try document.select("[class*='social']").remove()
        try document.select("[class*='share']").remove()
        try document.select("[class*='cookie']").remove()
        try document.select("[class*='popup']").remove()
        try document.select("[class*='modal']").remove()
        try document.select("[class*='banner']").remove()
        // Remove hidden elements
        try document.select("[style*='display:none']").remove()
        try document.select("[style*='display: none']").remove()
        try document.select("[hidden]").remove()
        try document.select("[aria-hidden='true']").remove()
        // Remove email-specific noise
        try document.select("[class*='signature']").remove()
        try document.select("[class*='disclaimer']").remove()
        // Extract text content
        let text = try document.text()
        // Filter out lines with excessive slashes (likely encoded data or URLs)
        var lines: [String] = text.split(separator: "\n").map({ String($0) })
        let slashThresholdPercent: Float = 0.15
        lines = lines.map { line in
            let slashCount: Int = line.components(separatedBy: "/").count - 1
            let slashPercent: Float = Float(slashCount) / Float(line.count)
            if slashPercent > slashThresholdPercent {
                return nil
            }
            return line
        }.compactMap({ $0 })
        // Clean up whitespace in remaining lines
        lines = lines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return lines.joined(separator: "\n")
    }
	
}

