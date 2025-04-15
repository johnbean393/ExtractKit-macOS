//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import CoreXLSX
import Foundation
import FSKit_macOS

public class ExcelExtractor: FileExtractor {
	
	public required init(
        url: URL,
        speed: ExtractionSpeed = .default
    ) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"xlsx",
		"xlsb"
	]
	
	public func extractText() async throws -> String {
		// Get file path
		let path: String = self.url.posixPath
		// Init tables variable
		var tables: [Table] = []
		// Init XLSX object
		guard let xlsxFile: XLSXFile = XLSXFile(filepath: path) else {
			throw ExcelError.failedToReadFile
		}
		// Get shared strings
		let sharedStrings: SharedStrings? = try? xlsxFile.parseSharedStrings()
		// Get sheets
		let worksheetPaths: [String] = try xlsxFile.parseWorksheetPaths()
		let worksheets: [Worksheet] = try worksheetPaths.map({ path in
			try xlsxFile.parseWorksheet(at: path)
		})
		// For each sheet
		for worksheet in worksheets {
			// If data exists
			guard let data = worksheet.data else { continue }
			let table: Table = self.getDataTable(
				data: data,
				sharedStrings: sharedStrings
			)
			tables.append(table)
		}
		// Convert tables to markdown
		let tablesAsMd: [String] = tables.map({ $0.asMarkdown })
		let markdown: String = tablesAsMd.joined(separator: "\n\n")
		// Return result
		return markdown
	}
	
	private func getDataTable(
		data: Worksheet.Data,
		sharedStrings: SharedStrings?
	) -> Table {
		// Convert data to 2D array
		let array: [[String]] = data.rows.map({ row in
			row.cells.map({ cell in
				// If no shared values
				if let sharedStrings {
					return cell.stringValue(sharedStrings) ?? ""
				} else {
					return cell.value ?? ""
				}
			})
		})
		// Return table
		return Table(data: array)
	}
	
	public enum ExcelError: LocalizedError {
        
		case failedToReadFile
        
        public var errorDescription: String? {
            switch self {
                case .failedToReadFile:
                    return "Failed to read file"
            }
        }
        
	}
	
}
