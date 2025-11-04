//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation
import SwiftSoup

public class WebsiteExtractor: FileExtractor {
    
    public required init(
        url: URL,
        speed extractionSpeed: ExtractionSpeed = .default
    ) {
        self.url = url
    }
    
    public var url: URL
    
    public static let fileExtensions: [String] = []
    
    public func extractText() async throws -> String {
        // Get website content
        let urlRequest = URLRequest(url: self.url)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
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
        
        // Remove comments (SwiftSoup doesn't have direct comment removal, handled by parsing)
        
        // Extract text content with preserved structure
        let text = try document.text()
        
        // Clean up whitespace
        let cleanedText = text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        return cleanedText
    }
    
}
