import SwiftUI

struct EpisodeRootView: View {
    var feed: Feed

    var body: some View {
        List {
            ForEach(feed.sections) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.episodes) { episode in
                        EpisodeCell(episode: episode)
                    }
                }
            }

            HStack {
                Spacer()
                Text("\(feed.episodes.count) episodes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .navigationTitle("Episodes")
    }
}

private struct EpisodeCell: View {
    var episode: Episode

    var body: some View {
        VStack(alignment: .leading) {
            Text(episode.title)
            Text(episode.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews

struct EpisodeRootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EpisodeRootView(feed: Feed.testData[0])
        }
    }
}
