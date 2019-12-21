//
//  RelationsParsers.swift
//  neuCKAN
//
//  Created by you on 19-12-20.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import os.log

/**
Returns a `Relations` instance from given JSON data.

This function first serialises the JSON data from `data` and type cast it to `[Any]`, then passes it to `relationsParser(parses serialisedData: [Any]) -> Set<Relations>?` to parse it recursively.

- Parameter data: A Data object contatining JSON data.

- Returns: A `Relations` instance from the JSON data in `data`, or `nil` if an error orcurs or if the JSON data is empty.
*/
func relationsParser(parses data: Data) -> Relations? {
	//	It is technically possible to have a JSON object, instead of a JSON array, on the top-level. However the CKAN metadata specification forbids it.
	guard let serialisedData = try? JSONSerialization.jsonObject(with: data) as? [Any]
		else { os_log("Unable to serialize JSON data and type cast to [Any].", type: .debug); return nil }
	guard let relationsSet = relationsParser(parses: serialisedData)
		else { os_log("Unable to parse serialized JSON data.", type: .debug); return nil }
	guard !relationsSet.isEmpty
		else { os_log("Empty Relations set returned from parsing serialised JSON data.", type: .debug); return nil }
	if relationsSet.count == 1 {
		return relationsSet.first
	} else {
		//	if the top-level in JSON data is an array, it can't be an "any_of" value
		return Relations.allOfRelations(relationsSet)
	}
}

/**
Returns a `Relations` instance from given `[Any]`.

- Parameter serialisedData: An `[Any]` contatining serialised JSON data.

- Returns: A `Relations` instance from the JSON data in `serialisedData`, or `nil` if an error orcurs or if the JSON data is empty.
*/
fileprivate func relationsParser(parses serialisedData: [Any]) -> Set<Relations>? {
	//	these String values are defined by the CKAN metadata specification
	let anyOfKey: String = "any_of"
	let mandatoryKey: String = "name"
	
	let decoder = JSONDecoder()
	
	var relationsSet: Set<Relations> = []
	
	for value in serialisedData {
		if let object = value as? [String: Any] {
			if object.keys.contains(anyOfKey) && object.count == 1 {
				guard let extractedValue = object[anyOfKey] as? [Any]
					else { os_log("Unable to type cast the Foundation representation of an \"any_of\" JSON array to [Any].", type: .debug); continue }
				guard let newRelations = relationsParser(parses: extractedValue)
					else { os_log("Unable to parse the [Any] representing an \"any_of\" JSON array to a Set<Relations>.", type: .debug); continue }
				relationsSet.insert(Relations.anyOfRelations(newRelations))
			} else if object.keys.contains(mandatoryKey) {
				guard let objectData = try? JSONSerialization.data(withJSONObject: object)
					else { os_log("Unable to revert the [String: Any] representing a serialised JSON object back to a Data object.", type: .debug); continue }
				guard let relation = try? decoder.decode(Relation.self, from: objectData)
					else { os_log("Unable to parse the [String: Any] representing a serialised JSON object to a Relation instance.", type: .debug); continue }
				relationsSet.insert(Relations.leafRelation(relation))
			} else {
				continue
			}
		} else if let array = value as? [Any] {
			guard let newRelations = relationsParser(parses: array)
				else { os_log("Unable to parse the [Any] representing an JSON array of serialised JSON object to a Set<Relations>.", type: .debug); continue }
			relationsSet.insert(Relations.allOfRelations(newRelations))
		} else {
			continue
		}
	}
	
	return relationsSet
}
