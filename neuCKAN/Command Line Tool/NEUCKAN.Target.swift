//
//	NEUCKAN.Target.swift
//	neuckan
//
//	Created by you on 20-03-07.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import ArgumentParser

extension NEUCKAN {
	struct Target: ParsableCommand {
//		static let configuration = CommandConfiguration(
//			commandName: <#T##String?#>,
//			abstract: <#T##String#>,
//			discussion: <#T##String#>,
//			shouldDisplay: <#T##Bool#>,
//			subcommands: <#T##[ParsableCommand.Type]#>,
//			defaultSubcommand: <#T##ParsableCommand.Type?#>,
//			helpNames: <#T##NameSpecification#>
//		)
		
		@Argument(help: "Index to the target.")
		var targetNumber: Int?
		
		@Argument(help: "Path to the target.")
		var targetPath: String?
		
	}
}
