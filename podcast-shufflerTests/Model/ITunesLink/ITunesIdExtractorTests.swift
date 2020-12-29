import Foundation
import XCTest
@testable import podcast_shuffler

class ITunesIdExtractorTests: XCTestCase {
    func testIdExtraction() {
        let expectations: [URL: String] = [
            URL(string: "https://podcasts.apple.com/us/podcast/the-joe-rogan-experience/id360084272")!: "360084272",
            URL(string: "https://podcasts.apple.com/no/podcast/forklart/id1437259636")!: "1437259636",
        ]

        let extractor = ITunesIdExtractor()
        for (url, id) in expectations {
            XCTAssertEqual(id, extractor.extractId(from: url))
        }
    }
}
