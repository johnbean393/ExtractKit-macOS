//
//  File.swift
//  ExtractKit-macOS
//
//  Created by Bean John on 10/3/24.
//

import Foundation
import PDFKit

public class PdfExtractor: FileExtractor {
	
	public required init(url: URL) {
		self.url = url
	}
	
	public var url: URL
	
	public static let fileExtensions: [String] = [
		"pdf"
	]
	
	public func extractText() async throws -> String {
		// Init pdf document
		guard let pdf = PDFDocument(url: url) else {
			throw PdfError.failedToReadFile
		}
		let pageCount = pdf.pageCount
        var documentContent: String = ""
		// Extract contents of each page
		for pageIndex in 0..<pageCount {
			// Get text content
			guard let page: PDFPage = pdf.page(at: pageIndex) else {
				continue
			}
			guard let pageContent: NSAttributedString = page.attributedString else {
				continue
			}
			// Check if text is reversed
			if pageContent.string.components(separatedBy: " ,").count >= 3 || pageContent.string.components(separatedBy: " .").count >= 5 {
				// If reversed, add reversed string
				documentContent += pageContent.string.reduce("") { "\($1)" + $0 }
			} else {
				// If not reversed, add normal string
                documentContent += pageContent
			}
            // Add new line
            documentContent += "\n"
            // Get image content
            let images: [NSImage] = self.getPdfPageImage(page: page)
            let texts: [String] = await images.asyncMap { image in
                do {
                    return try await ImageExtractor.extractNSImage(nsImage: image)
                } catch {
                    return nil
                }
            }.compactMap({ $0 })
            let imagesText: String = texts.joined(separator: " ")
            // Add to document content
            documentContent += imagesText
			// Add new line
            documentContent += "\n"
		}
		// Return text
		return documentContent
	}
    
    /// Function to get all images in the
    private func getPdfPageImage(page: PDFPage) -> [NSImage] {
        // Get page in CoreGraphics format
        guard let cgPdfPage: CGPDFPage = page.pageRef, let dictionary = cgPdfPage.dictionary else {
            return []
        }
        var res: CGPDFDictionaryRef?
        guard CGPDFDictionaryGetDictionary(dictionary, "Resources", &res), let resources = res else {
            return []
        }
        var xObj: CGPDFDictionaryRef?
        guard CGPDFDictionaryGetDictionary(resources, "XObject", &xObj), let xObject = xObj else {
            return []
        }
        // Enumerate all of the keys in 'dict', calling the block-function `block' once for each key/value pair.
        var imageKeys = [String]()
        CGPDFDictionaryApplyBlock(
            xObject,
            { key, object, _ in
                var stream: CGPDFStreamRef?
                guard CGPDFObjectGetValue(object, .stream, &stream),
                      let objectStream = stream,
                      let streamDictionary = CGPDFStreamGetDictionary(objectStream) else {
                    return true
                }
                var subtype: UnsafePointer<Int8>?
                guard CGPDFDictionaryGetName(streamDictionary, "Subtype", &subtype), let subtypeName = subtype else {
                    return true
                }
                if String(cString: subtypeName) == "Image" {
                    imageKeys.append(String(cString: key))
                }
                return true
            },
            nil
        )
        // Get images
        let allPageImages = imageKeys.compactMap { imageKey -> NSImage? in
            var stream: CGPDFStreamRef?
            guard CGPDFDictionaryGetStream(xObject, imageKey, &stream), let imageStream = stream else {
                return nil
            }
            var format: CGPDFDataFormat = .raw
            guard let data = CGPDFStreamCopyData(imageStream, &format) else {
                // Fall back on converting the entire page to an NSImage
                let pageSize: CGSize = page.bounds(for: .mediaBox).size
                let pdfImage = page.thumbnail(of: pageSize, for: .mediaBox)
                return pdfImage
            }
            guard let image = NSImage(data: data as Data) else {
                // Fall back on converting the entire page to an NSImage
                let pageSize: CGSize = page.bounds(for: .mediaBox).size
                let pdfImage = page.thumbnail(of: pageSize, for: .mediaBox)
                return pdfImage
            }
            return image
        }
        return allPageImages
    }
	
	public enum PdfError: Error {
		case failedToReadFile
	}
	
}
