//
//  FileURLConvertible.swift
//  neuCKAN
//
//  Created by you on 20-03-04.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A type that can represent a file URL.
*/
protocol FileURLConvertible {
	/**
	Returns a file URL from the conforming instance.
	
	- Returns: The file URL converted from the conforming instance.
	*/
	func asFileURL() -> URL
}

//enum FileURLConversionError: LocalizedError {
//	case invalidFileURL(fileURL: FileURLConvertible)
//}

/**
A type that can be represented as a file URL in a lossless, unambiguous way.
*/
protocol LosslessFileURLConvertible: FileURLConvertible {
	/**
	Instantiates an instance of the conforming type from a file URL representation.
	
	- Parameter fileURL: The file URL to initialise the instance with.
	*/
	init?(_ fileURL: URL)
}

extension URL: LosslessFileURLConvertible {
	/**
	Instantiates a URL instance from the given file URL.
	
	- Parameter fileURL: The file URL to initialise the instance with.
	
	- Returns: `nil` if `fileURL` is not a file URL.
	*/
	init?(_ fileURL: URL) {
		guard fileURL.isFileURL else { return nil }
		self = fileURL
	}
	/**
	Returns a file URL from `self`.
	
	- Returns: The file URL converted from `self`.
	*/
	func asFileURL() -> URL {
		return URL(fileURLWithPath: self.path)
	}
}

extension String: LosslessFileURLConvertible {
	/**
	Creates a string from the given file URL.
	
	- Parameter fileURL: The file URL to create the string with.
	
	- Returns: `nil` if `fileURL` is not a file URL.
	*/
	init?(_ fileURL: URL) {
		guard fileURL.isFileURL else { return nil }
		self = fileURL.path
	}
	/**
	Returns a file URL from `self`.
	
	- Returns: The file URL converted from `self`.
	*/
	func asFileURL() -> URL {
		return URL(fileURLWithPath: self)
	}
}
