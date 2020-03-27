//
//  NEUCKAN.swift
//  neuckan
//
//  Created by you on 20-03-07.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import ArgumentParser

struct NEUCKAN: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "not entirely unlike CKAN.",
		subcommands: [Target.self]
	)
	private enum ModDeveloperMode: String, ExpressibleByArgument {
		case on, off
	}
	
	@Option()
	private var modDeveloperMode: ModDeveloperMode?
	
	func run() throws {
		print(
			"""
			                                              ▁▄▄████████▌  ▐█▌         ▟█▛         ▄▇█▇▄          ▄██▇▄       ▐█▌
			                                            ▗██▀▀▔▔▔▔▔▔▔▔ ̇  ▐█▌        ▟█▛         ▟█▛▔▜█▙        ▐█▛▔▜█▙      ▐█▌
			▗▆▆▆▆▆▆▅▄▂      ̣▄▆▆▆▆▆▆▅▖   ▐█▌       ▐█▌  ▗█▛              ▐█▌      ▁▟█▛         ▟█▛   ▜█▙       ▐█▌  ▜█▙     ▐█▌
			▐█▛▀▀▀▀▀▜██▖  ▗█▛▀▀▀▀▀▀▜█▖  ▐█▌       ▐█▌  ▐█▌              ▐█▙▄▄▄▄▟██▀▔         ▟█▛     ▜█▙      ▐█▌   ▜█▙    ▐█▌
			▐█▌      ▐█▌  ▐█▌▁▁▁▁▁▂▅█▘  ▐█▌       ▐█▌  ▐█▌              ▐█▛▀▀▀▀▜██▄▁        ▟█▛       ▜█▙     ▐█▌    ▜█▙   ▐█▌
			▐█▌      ▐█▌  ▐█▛▀▀▀▀▀▀▔    ▐█▌       ▐█▌  ▝█▙              ▐█▌      ▔▜█▙      ▟█▛         ▜█▙    ▐█▌     ▜█▙  ▐█▌
			▐█▌      ▐█▌  ▝█▙▁▁▁▁▁▁▁▁   ▝█▙▂▁▁▁▁▁▂▟█▘   ▝██▄▄▁▁▁▁▁▁▁▁ ̣  ▐█▌        ▜█▙    ▟█▛           ▜█▙   ▐█▌      ▜█▙▁▟█▌
			▐█▌      ▐█▌   ▔▀▜███████     ▀▜█████▛▀       ▔▀▀████████▌  ▐█▌         ▜█▙  ▟█▛             ▜█▙  ▐█▌       ▀▜██▀
			"""
		)
	}
}
