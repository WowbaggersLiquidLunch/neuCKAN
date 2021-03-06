//
//	Hash.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

//	TODO: Reimplement with either Swift Crypto or Apple CryptoKit.

import Foundation

/**
Mod hash digests.

This is equivalent to the ["download_hash" attribute][0] in a .ckan file.

It's the SHA1 and SHA256 calculated hashes of the resulting file downloaded.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#download_hash
*/
struct Hash: Hashable, Codable {
	let sha1: String?
	let sha256: String?
}
