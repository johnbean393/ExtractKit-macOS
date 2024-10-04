<h1 align="center">ExtractKit-macOS</h1>

A Swift Package for extracting text from files and websites on macOS.

## Usage

- Extracting text

```
let url: URL = URL(string: "https://github.com/johnbean393")!
let extractedText: String = try await ExtractKit.shared.extractText(
	url: url
)
print("extractedText: \(extractedText)")
```

- Supporting a custom file format

```
// Define class
class AudioExtractor: FileExtractor {
	
	required init(url: URL) {
		self.url = url
	}
	
	var url: URL
	
	static let fileExtensions: [String] = [
		"mp3", 
		"wav"
	]
	
	public func extractText() async throws -> String {
		// Code to extract text here
	}
	
}

// Make ExtractKit aware of the new file extractor
ExtractKit.shared.addFileExtractor(AudioExtractor)
```

## Installation

**Requirements**
- Xcode ≤ 15

**Swift Package Manager**
```
dependencies: [
	.package(url: "https://github.com/johnbean393/ExtractKit-macOS", branch: "main")
]
```

## Contributing

Contributions are very welcome. Let's make ExtractKit-macOS simple and powerful.
