//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/4/24.
//

import Foundation

public protocol TextExtractor {
	
    init(url: URL, speed: ExtractionSpeed)
	
	/// Property containing the URL of a file / website
	var url: URL { get set }
	
	/// Function to extract text
	func extractText() async throws -> String
	
}

public protocol FileExtractor: TextExtractor {
	
	/// A list of files formats the extractor is able to extract text from
	static var fileExtensions: [String] { get }
	
}

public protocol WebExtractor: TextExtractor {  }
