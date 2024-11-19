//
//  SpotifyAPIManager.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import Foundation

class SpotifyAPIManager: ObservableObject {
    
    var accessToken: String
    var tokenType: String
    
    init() {
        self.accessToken = ""
        self.tokenType = ""
    }
    
    init(access: String, token: String) {
        self.accessToken = access
        self.tokenType = token
    }
    
    func search(query: String, type: String) async throws -> SearchResponse? {
        // Format the query
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+")
        let urlStr = "https://api.spotify.com/v1/search?q=\(formattedQuery)&type=\(type)&market=US&limit=50&offset=0"
        let authorizationAccessTokenStr = accessToken
        let authorizationTokenTypeStr = tokenType
        let requestHeaders: [String: String] = ["Authorization": "\(authorizationTokenTypeStr) \(authorizationAccessTokenStr)"]
        
        // Create the URL request
        guard let url = URL(string: urlStr) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = requestHeaders
        
        do {
            // Perform the network call asynchronously
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for a valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            // Decode the response into `SearchResponse`
            let responseObject = try JSONDecoder().decode(SearchResponse.self, from: data)
            return responseObject
            
        } catch {
            // Handle errors
            print("Error occurred during the search: \(error)")
            throw error
        }
    }
}
