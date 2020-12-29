import Foundation
import XCTest
@testable import podcast_shuffler

class ITunesLinkExtractorTests: XCTestCase {
    func testLinkExtraction() {
        let client = MockHttpClient()
        client.response = .success(testResponse.data(using: .utf8))

        let exp = expectation(description: "completed")
        let extractor = ITunesLinkExtractor(httpClient: client)
        extractor.extractLink(forId: "1437259636", completion: { result in
            defer { exp.fulfill() }
            guard case let .success(url) = result else {
                XCTFail("Failed to extract URL")
                return
            }

            XCTAssertEqual("https://podcast.stream.schibsted.media/ap/100194?podcast", url.absoluteString)
        })

        wait(for: [exp], timeout: 1)
    }
}

// MARK: - Test data

fileprivate let testResponse = """
{
  "resultCount": 1,
  "results": [
    {
      "wrapperType": "track",
      "kind": "podcast",
      "collectionId": 1437259636,
      "trackId": 1437259636,
      "artistName": "Aftenposten",
      "collectionName": "Forklart",
      "trackName": "Forklart",
      "collectionCensoredName": "Forklart",
      "trackCensoredName": "Forklart",
      "collectionViewUrl": "https://podcasts.apple.com/us/podcast/forklart/id1437259636?uo=4",
      "feedUrl": "https://podcast.stream.schibsted.media/ap/100194?podcast",
      "trackViewUrl": "https://podcasts.apple.com/us/podcast/forklart/id1437259636?uo=4",
      "artworkUrl30": "https://is4-ssl.mzstatic.com/image/thumb/Podcasts114/v4/32/90/40/32904016-3f87-327d-c72a-a0eff3f9886f/mza_6866881176712937853.png/30x30bb.jpg",
      "artworkUrl60": "https://is4-ssl.mzstatic.com/image/thumb/Podcasts114/v4/32/90/40/32904016-3f87-327d-c72a-a0eff3f9886f/mza_6866881176712937853.png/60x60bb.jpg",
      "artworkUrl100": "https://is4-ssl.mzstatic.com/image/thumb/Podcasts114/v4/32/90/40/32904016-3f87-327d-c72a-a0eff3f9886f/mza_6866881176712937853.png/100x100bb.jpg",
      "collectionPrice": 0,
      "trackPrice": 0,
      "trackRentalPrice": 0,
      "collectionHdPrice": 0,
      "trackHdPrice": 0,
      "trackHdRentalPrice": 0,
      "releaseDate": "2020-12-28T04:25:00Z",
      "collectionExplicitness": "cleaned",
      "trackExplicitness": "cleaned",
      "trackCount": 579,
      "country": "USA",
      "currency": "USD",
      "primaryGenreName": "Daily News",
      "contentAdvisoryRating": "Clean",
      "artworkUrl600": "https://is4-ssl.mzstatic.com/image/thumb/Podcasts114/v4/32/90/40/32904016-3f87-327d-c72a-a0eff3f9886f/mza_6866881176712937853.png/600x600bb.jpg",
      "genreIds": [
        "1526",
        "26",
        "1489"
      ],
      "genres": [
        "Daily News",
        "Podcasts",
        "News"
      ]
    }
  ]
}
"""
