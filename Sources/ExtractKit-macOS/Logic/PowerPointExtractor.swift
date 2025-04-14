//
//  PowerPointExtractor.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation
import FSKit_macOS

public class PowerPointExtractor: FileExtractor {
	
	public required init(
        url: URL,
        speed: ExtractionSpeed = .default
    ) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"pptx"
	]
	
	public func extractText() async throws -> String {
		// Get POSIX path
		let path: String = self.url.posixPath
		// Make UUID
		let archiveId: UUID = UUID()
		// Create temp directory
		let appSupportDir: URL = URL.applicationSupportDirectory
		let tempDirectory: URL = appSupportDir
			.appendingPathComponent(
				"Cache"
			).appendingPathComponent(
				archiveId.uuidString
			)
		try? FileManager.default.createDirectory(
			at: tempDirectory,
			withIntermediateDirectories: true
		)
		// Unzip to temporary directory
		let command: String = """
cd "\(tempDirectory.posixPath)";unzip \"\(path)\"; cd ppt/slides; echo \"-<>-<>-separator-<>-<>-\"; grep -r -h -E -o '<a:t>[^<]*</a:t>' . | sed -E 's/<[^>]*>//g' | grep -v '^./slide.*'
"""
		let unzipResult: String = self.runCommand(
			command: command
		)
		// Kill lingering processes
		let _ = self.runCommand(command: "killall grep")
		// Check if success
		guard unzipResult.contains("-<>-<>-separator-<>-<>-\n") else {
			throw PowerPointError.failedToUnzipFile
		}
		// Process and return results
		let resultComponents: [String] = unzipResult.components(
			separatedBy: "-<>-<>-separator-<>-<>-\n"
		)
		let fileText: String = resultComponents[resultComponents.count - 1]
		// Delete temporary directory
		FileManager.removeItem(at: tempDirectory)
		// Return result
		return fileText
	}
	
	// Run a shell script
	private func runCommand(command: String) -> String {
		let task = Process()
		task.launchPath = "/bin/zsh"
		task.arguments = ["-c", command]
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = String(data: data, encoding: .utf8) ?? "No output"
		return output
	}
	
	public enum PowerPointError: Error {
		case failedToUnzipFile
	}
	
}
