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
        .animation(.default)
    }
}

private struct EpisodeCell: View {
    @State private var expanded: Bool = false
    var episode: Episode

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(episode.title)
                Text(episode.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(expanded ? nil : 3)
            }

            Spacer()
            VStack {
                Text("\(formattedDuration())")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .onTapGesture { expanded.toggle() }
        .animation(.default)
    }

    private func formattedDuration() -> String {
        let format = DateComponentsFormatter()
        format.zeroFormattingBehavior = .pad
        format.allowedUnits = [ .second, .minute, .hour ]

        return format.string(from: episode.duration) ?? ""
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
