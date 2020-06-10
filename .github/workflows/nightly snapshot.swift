//
//  nightly snapshot.swift
//  neuCKAN
//
//  Created by you on 20-05-22.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

let branch = bash("git rev-parse --abbrev-ref HEAD")
let headCommitSHA = bash("git rev-parse HEAD")
let tags = bash("git rev-parse --abbrev-ref --tags").split(separator: "\n")

let branchSnapshots = tags.filter { $0.hasPrefix("neuCKAN-\(branch)-snapshot-") }
let branchSnapshotsAreOutdated = branchSnapshots.allSatisfy { bash("git show-ref -s \($0)") != headCommitSHA }

guard branchSnapshotsAreOutdated else { exit(EXIT_SUCCESS) }

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
	
	guard let standardOutput = String(data: data, encoding: .utf8) else {
		FileHandle.standardError.write(Data("Error in reading standard output data".utf8))
		exit(EXIT_FAILURE)
	}
	
	if standardOutput.last == "\n" {
		var standardOutputCopy = standardOutput
		standardOutputCopy.removeLast()
		return standardOutputCopy
	} else {
		return standardOutput
	}
}
