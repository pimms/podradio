import Foundation

class HttpClient {
    private enum HttpError: Error {
        case unexpectedStatusCode
    }

    private lazy var session = URLSession(configuration: .default)

    func get(_ url: URL, handler: @escaping (Result<Data?, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                handler(.failure(error))
            } else if let data = data,
                      let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) {
                handler(.success(data))
            } else {
                handler(.failure(HttpError.unexpectedStatusCode))
            }
        }

        task.resume()
    }
}
