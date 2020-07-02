//
//	AirTrafficControl.swift
//	neuCKAN
//
//	Created by you on 20-02-09.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	Acronym for Air Traffic Control.
typealias ATC = AirTrafficControl
///	The main controller for managing queues and file system-facing tasks.
class AirTrafficControl {
	///	Initialises a `AirTrafficControl` instance.
	private init() {}
	///	The shared, and only, `AirTrafficControl` instance of this neuCKAN instance.
	static let shared = ATC()
	///	A group of CKAN metadata-parsing tasks.
	let metadataParsingGroup = DispatchGroup()
	///	A queue for synchronously and sequentially checking and altering the state of data and the operations thereof.
	///
	///	It has to be synchronous and sequential to avoid data-racing.
	///	Its priority is set to the highest: user-interactive Quality of Service.
	///
	///	Admittedly, this might not be the most efficient way of doing it.
	///	However, it's better than using traditional locks.
	///	See [relevant Apple Developer video][Apple Developer video on synchronization].
	///
	///	[Apple Developer video on synchronization]: https://developer.apple.com/videos/play/wwdc2016/720/?time=1076
	let dataStateQueue = DispatchQueue(label: "com.neuCKAN.state", qos: .userInteractive)
	///	A queue for concurrently handling local file I/O.
	let concurrentFileIOQueue = DispatchQueue(label: "com.neuCKAN.concurrentFileIO", qos: .utility, attributes: .concurrent)
	///	A queue for concurrently handling network I/O.
	let concurrentNetworkIOQueue = DispatchQueue(label: "com.neuCKAN.concurrentNetworkIO", qos: .utility, attributes: .concurrent)
	///	A queue for concurrently handling network responses.
	let concurrentNetworkResponseQueue = DispatchQueue(label: "com.neuCKAN.concurrentNetworkResponse", qos: .utility, attributes: .concurrent)
	///	A queue for concurrently parsing CKAN metadata.
	let concurrentCKANMetadataParsingQueue = DispatchQueue(label: "com.neuCKAN.concurrentCKANMetadataParsing", qos: .utility, attributes: .concurrent)
	///	A queue for assembling mod releases into a collection of mods.
	let modsAssemblyQueue = DispatchQueue(label: "com.neuCKAN.modsAssembly", qos: .utility)
	///	A queue for setting `Synecdoche.shared.targets`.
	let targetsUpdateQueue = DispatchQueue(label: "com.neuCKAN.targetsUpdate", qos: .utility)
	///	A queue for setting `Synecdoche.shared.mods`.
	let modsUpdateQueue = DispatchQueue(label: "com.neuCKAN.modsUpdate", qos: .utility)
	///	A flag that indicates whether neuCKAN is parsing CKAN metadata.
	@Published var metadataUpdateIsInProgress: Bool = false {
		didSet {}
	}
	///	A flag that indicates whether targets are reloading.
	@Published var targetsReloadIsInProgress: Bool = false {
		didSet {}
	}
	///	A flag that indicates whether neuCKAN is adding new targets.
	@Published var targetsAdditionIsInProgress: Bool = false {
		didSet {}
	}
	///	A flag that indicates whether there is any change to targets in progress.
	var targetsDataUpdateIsInProgress: Bool { targetsReloadIsInProgress || targetsAdditionIsInProgress }
	///	A flag that indicates whether there is any data update in progress.
	var dataUpdateIsInProgress: Bool { metadataUpdateIsInProgress || targetsDataUpdateIsInProgress }
}
