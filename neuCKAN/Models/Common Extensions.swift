//
//  Common Extensions.swift
//  neuCKAN
//
//  Created by you on 20-05-22.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

extension NSRegularExpression: Comparable {
	public static func < (lhs: NSRegularExpression, rhs: NSRegularExpression) -> Bool {
		return lhs.pattern < rhs.pattern
	}
}

