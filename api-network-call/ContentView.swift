//
//  ContentView.swift
//  api-network-call
//
//  Created by Saul on 2023/07/06.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) {
                image in image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width:120, height: 120)
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(user?.login ?? "login placeholder")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "bio placeholder")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invlid URL")
            } catch GHError.invalidResponse {
                print("invalid response")
            } catch GHError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/twostraws"
        
        guard let url = URL(string: endpoint) else {throw GHError.invalidURL}
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
