import Foundation
@testable import podcast_shuffler

class MockHttpClient: HttpClient {
    var response: Result<Data?,Error>?

    override func get(_ url: URL, handler: @escaping (Result<Data?, Error>) -> Void) {
        if let response = response {
            DispatchQueue.main.async { handler(response) }
        } else {
            super.get(url, handler: handler)
        }
    }
}
