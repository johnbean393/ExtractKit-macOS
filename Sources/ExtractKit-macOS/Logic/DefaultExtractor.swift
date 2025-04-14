//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation

public class DefaultExtractor: FileExtractor {
	
	public required init(
        url: URL,
        speed: ExtractionSpeed = .default
    ) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"c",
		"html",
		"java",
		"js",
		"json",
		"log",
		"py",
		"rtf",
		"sh",
		"swift",
		"txt",
	]
	
	public func extractText() async throws -> String {
		let text: String = try String(contentsOf: url, encoding: String.Encoding.utf8)
		return text
	}
	
}
