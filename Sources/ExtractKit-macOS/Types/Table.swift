//
//  Table.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/2/24.
//

import Foundation

public struct Table: Identifiable, Codable {
	
	init(data: [[Any]]) {
		self.data = data.map({ row in
			return row.map({ data in
				return "\(data)"
			})
		})
	}
	
	/// Property storing the ID of a table
	public var id: UUID = UUID()
	
	/// Property storing all data inside the table
	public var data: [[String]]
	
	/// Computed property returning the number of columns in the table
	public var colCount: Int {
		return headers.count
	}
	
	/// Computed property returning the number of rows in the table
	public var rowCount: Int {
		return data.count
	}
	
	/// Computed property returning the headers of the table
	private var headers: [String] {
		return data.first ?? []
	}
	
	/// Computed property returning the table's contents as a markdown string
	public var asMarkdown: String {
		// Declare variables
		var markdown: String = ""
		let linebreak: String = "|\n"
		// Write table
		for colHeader in headers {
			markdown += "|\(colHeader)"
		}
		markdown += linebreak
		for _ in headers.indices {
			markdown += "|-"
		}
		for row in Array(data.dropFirst()) {
			markdown += linebreak
			for cell in row {
				markdown += "|\(cell)"
			}
		}
		markdown += "|"
		// Return string
		return markdown
	}
	
}
