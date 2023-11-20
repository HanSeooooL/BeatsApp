//
//  ContentView.swift
//  BeatsApp
//
//  Created by 한설 on 2023/11/20.
//

import SwiftUI
import MusicKit

struct Item: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let artist: String
    let imageUrl: URL?
}

struct ContentView: View {
    @State var songs = [Item]()
    @State var SearchKeyword: String = "" //State
    var body: some View {
        VStack {
            SearchBar(text: $SearchKeyword)
            NavigationView {
                List(songs) { song in
                    HStack {
                        AsyncImage(url: song.imageUrl)
                            .frame(width: 75, height: 75, alignment: .center)
                        VStack(alignment: .leading) {
                            Text(song.name)
                                .font(.title3)
                            Text(song.artist)
                                .font(.footnote)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                fetchMusic()
            }
        }
    }
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Happy", types: [Song.self])
        request.limit = 25
        return request
    }()
    private func fetchMusic() {
        Task{
            // Request permission
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                // Request -> Response
                do {
                    let result = try await request.response()
                    self.songs = result.songs.compactMap({
                        return .init(name: $0.title, artist: $0.artistName, imageUrl: $0.artwork?.url(width: 75, height: 75))
                    })
                    print(String(describing: songs[0]))
                } catch {
                    print(String(describing: error))
                }
                // Assigns songs
            default:
                break;
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchBar: View {
    
    @Binding var text: String
 
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
 
                TextField("Search", text: $text)
                    .foregroundColor(.primary)
 
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                } else {
                    EmptyView()
                }
            }
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
        }
        .padding(.horizontal)
    }
}
