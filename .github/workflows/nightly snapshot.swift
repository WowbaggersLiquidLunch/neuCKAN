//
//  nightly snapshot.swift
//  neuCKAN
//
//  Created by you on 20-05-22.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

let branch = bash("git rev-parse --abbrev-ref HEAD").split(separator: "\n")[0]
let headCommitSHA = bash("git rev-parse HEAD")
let tags = bash("git rev-parse --abbrev-ref --tags").split(separator: "\n")

let lastTag = tags.first(where: { tag in
	let tagComponents = tag.split(separator: "-")
	return tagComponents.count > 1 && tagComponents[1] == branch
})

guard lastTag == nil || bash("git rev-parse \(lastTag!)") != headCommitSHA else { exit(EXIT_SUCCESS) }

let date = Date()
let dateFormatter = ISO8601DateFormatter()

dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]

print("neuCKAN-\(branch)-snapshot-\(dateFormatter.string(from: date))")

/// Executes a shell command with `/bin/bash`.
/// - Parameter command: The command to execute.
/// - Returns: The standard output from executing `command`.
@discardableResult
func bash(_ command: String) -> String {
	let process = Process()
	let pipe = Pipe()
	
	process.standardOutput = pipe
	process.arguments = ["-c", command]
	process.executableURL = URL(fileURLWithPath: "/bin/bash")
	try! process.run()
	//	process.waitUntilExit()
	
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	return String(data: data, encoding: .utf8)!
}
