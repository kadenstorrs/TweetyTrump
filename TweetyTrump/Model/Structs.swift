//
//  Structs.swift
//  TweetyTrump
//
//  Created by Kaden Storrs on 7/12/20.
//  Copyright © 2020 Kaden Storrs. All rights reserved.
//

import Foundation

struct Tweet: Codable {
    var value: String
    var created_at: String
}


enum TweetError: Error {
    case failed
}

protocol TrumpTweetController {
    func getTweet(completion: @escaping (Result<Tweet, TweetError>) -> Void)
}

class TrumpTweetNetworkController: TrumpTweetController {
    
    
    let baseURL = URL(string: "https://pokeapi.co/api/v2/")!
    let session = URLSession.shared
    let path = "pokemon"

    
    func getTweet(completion: @escaping (Result<Tweet, TweetError>) -> Void) {
        let headers = [
            "x-rapidapi-host": "matchilling-tronald-dump-v1.p.rapidapi.com",
            "x-rapidapi-key": "acb25c97ffmshf3715d37a69e3b0p1f6073jsn2a6090dced1b",
            "accept": "application/hal+json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://matchilling-tronald-dump-v1.p.rapidapi.com/random/quote")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(.failure(.failed))
            } else {
                let decoder = JSONDecoder()
                
                do {
                    
                    let tweet = try decoder.decode(Tweet.self, from: data!)
                    completion(.success(tweet))
                } catch {
                    
                    print(error)
                    completion(.failure(.failed))
                }
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
        })
        dataTask.resume()
    }
    
}
