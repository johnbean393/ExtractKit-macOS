//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import SwiftCSV
import Foundation

public class CsvExtractor: FileExtractor {
	
	public required init(url: URL) {
		self.url = url
	}
	
	public var url: URL
	
	static public let fileExtensions: [String] = [
		"csv",
		"tsv"
	]
	
	public func extractText() async throws -> String {
		// Init as CSV file, guess delimiter
		let csv: CSV = try CSV<Enumerated>(
			url: self.url
		)
		// Read CSV
		let data: [[String]] = [csv.header] + csv.rows
		// Init table
		let table: Table = Table(data: data)
		// Return table as markdown
		return table.asMarkdown
	}
	
}
