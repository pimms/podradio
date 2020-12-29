import Foundation

private struct LookupResponse: Decodable {
    let results: [LookupResult]
}

private struct LookupResult: Decodable {
    let feedUrl: String
}

class ITunesLinkExtractor {
    private enum ExtractionError: Error {
        case urlError
        case noData
        case decodingError
        case noResults
    }

    private let httpClient: HttpClient

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    func extractLink(forId id: String, completion: @escaping (Result<URL,Error>) -> Void) {
        let urlString = "https://itunes.apple.com/lookup?entity=podcast&id=\(id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(ExtractionError.urlError))
            return
        }

        httpClient.get(url) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(ExtractionError.noData))
                    return
                }

                guard let response = try? JSONDecoder().decode(LookupResponse.self, from: data) else {
                    completion(.failure(ExtractionError.decodingError))
                    return
                }

                guard let firstResult = response.results.compactMap({ URL(string: $0.feedUrl) }).first else {
                    completion(.failure(ExtractionError.noResults))
                    return
                }

                completion(.success(firstResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
