import Foundation
import SwiftUI

struct ScheduleButton: View {
    var schedule: StreamSchedule
    @State var isPresenting = false

    var body: some View {
        Button(action: { isPresenting.toggle() }) {
            Image(systemName: "list.bullet")
                .resizable()
                .tint(.gray)
                .aspectRatio(contentMode: .fit)
        }.sheet(isPresented: $isPresenting) {
            ScheduleView(schedule: schedule)
                .presentationDetents([.fraction(0.3)])
        }
    }
}

struct ScheduleView: View {
    var schedule: StreamSchedule

    var filteredSchedule: [StreamAtom] {
        let now = Date()
        return schedule.todaysSchedule.filter({ $0.endTime >= now })
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ForEach(filteredSchedule, id: \.self) { atom in
                    AtomCell(atom: atom, isPlaying: schedule.atom == atom)
                }
            }
            .listStyle(.plain)
            .onAppear {
                scrollProxy.scrollTo(schedule.atom, anchor: .top)
            }
        }
    }
}

private struct AtomCell: View {
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    var atom: StreamAtom
    let isPlaying: Bool

    var body: some View {
        VStack() {
            Spacer().frame(height: 5)
            HStack(alignment: .center, spacing: 10) {
                Text(Self.dateFormatter.string(from: atom.startTime))
                    .monospacedDigit()
                    .bold()
                Text(atom.title)
                    .font(.body)
                Spacer()
                Text(atom.episode.season!.name!)
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
            progressBar()
        }
        .padding()
        .frame(minHeight: 30)
        .background(
            isPlaying
                ? Color.secondarySystemBackground
                : Color.clear
        )
    }

    func progressBar() -> some View {
        Group {
            VStack {
                if isPlaying {
                    let currentTime = atom.startTime.distance(to: Date())
                    ProgressView(value: currentTime, total: atom.duration)
                        .tint(.gray)
                } else {
                    Spacer().frame(height: 5)
                }
            }
        }
    }
}
