import Foundation
import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

enum AuthServiceError: Error {
    case invalidRequest
}

enum ProfileServiceError: Error {
    case invalidRequest
    case duplicateRequest
}


extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[data(for:)]: NetworkError.httpStatusCode(\(statusCode))")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[data(for:)]: NetworkError.urlRequestError — \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[data(for:)]: NetworkError.urlSessionError — Unknown error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })

        return task
    }

    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    let rawData = String(data: data, encoding: .utf8) ?? "nil"
                    print("[objectTask(for:)]: Decoding error — \(error.localizedDescription), Raw data: \(rawData)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask(for:)]: Failure — \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        return task
    }

}


