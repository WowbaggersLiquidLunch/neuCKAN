//
//  NEUCKAN.List.swift
//  neuckan
//
//  Created by you on 20-03-07.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import ArgumentParser

extension NEUCKAN {
	struct List: ParsableCommand {
		@Flag()
		var searchScope: SearchScope
		
		//	--forSelectedTargets
		//	--targets 1.9.0 1.8.2 1.2.3 path/to/target
		//	--tags physics science parts
	}
	
	enum SearchScope: String, CaseIterable {
		case all
		case installed
		case upgradable
	}
}
