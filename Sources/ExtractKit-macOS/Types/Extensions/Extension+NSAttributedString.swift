//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/2/24.
//

import AppKit
import Foundation

extension NSAttributedString {
	
	func paragraphStyle(at index: Int) -> NSParagraphStyle? {
		let key = NSAttributedString.Key.paragraphStyle
		return attribute(key, at: index, effectiveRange: nil) as? NSParagraphStyle
	}
	
	func textBlocks(at index:Int)->[NSTextBlock]?{
		return paragraphStyle(at: index)?.textBlocks
	}
	
	func tables(at index:Int)->[NSTextTable]?{
		guard let tbs = textBlocks(at: index) else{
			return nil
		}
		var output = Set<NSTextTable>()
		for tb in tbs{
			if let t = tb as? NSTextTableBlock{
				output.insert(t.table)
			}
		}
		return Array(output)
	}
	
	func getAllTables() -> [NSTextTable] {
		var tables: [NSTextTable] = []
		for index in 0..<self.length {
			if let tablesAtIndex = self.tables(at: index) {
				tables += tablesAtIndex
			}
		}
		return Array(Set(tables))
	}
	
}
