import Foundation
import Testing
@testable import ExtractKit_macOS

enum TestFiles: String {
	case docx = "Test.docx"
	case csv = "Test.csv"
	case tsv = "Test.tsv"
	case xlsx = "Test.xlsx"
	case pptx = "Test.pptx"
	case pdf = "Test.pdf"
	case png = "Test.png"
	
	var url: URL {
		let testFilesDirUrl: URL = URL(
			filePath: "/Users/bj/Library/Application Support/Magic Sorter/Sorted Land/Computer DN/Swift_Packages/ExtractKit-macOS/Tests/ExtractKit-macOSTests/Test Files/"
		)
		return testFilesDirUrl.appendingPathComponent(self.rawValue)
	}
}

enum TestSites: String {
	case gitHub = "https://github.com/johnbean393"
	case googleNews = "https://news.google.com/home?hl=en-US&gl=US&ceid=US:en"
	case youtube = "https://youtube.com"
	case markWittonBlog = "https://markwitton.co.uk"
	
	var url: URL {
		return URL(string: self.rawValue)!
	}
}

@Test func getSupportedFormats() async throws {
	print(
		"supportedFileFormats.count:",
		ExtractKit.shared.supportedFileFormats.count
	)
	print("supportedFileFormats:", ExtractKit.shared.supportedFileFormats)
}

@Test func fileTest() async throws {
	let testFile: TestFiles = .xlsx
	do {
		let extractedText: String = try await ExtractKit.shared.extractText(
			url: testFile.url
		)
		print("extractedText: \(extractedText)")
	} catch {
		print("error: \(error)")
	}
}

@Test func websiteTest() async throws {
	let testSite: TestSites = .markWittonBlog
	do {
		let extractedText: String = try await ExtractKit.shared.extractText(
			url: testSite.url
		)
		print("extractedText: \(extractedText)")
	} catch {
		print("error: \(error)")
	}
}
