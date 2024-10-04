//
//  Extensions+Array.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation

extension Array {
	func unique(_ selector: (Element, Element) -> Bool) -> [Element] {
		return reduce([Element]()) {
			if let last = $0.last {
				return selector(last, $1) ? $0 : $0 + [$1]
			} else {
				return [$1]
			}
		}
	}
}
