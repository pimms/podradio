import Foundation
import SwiftUI

struct SettingsRootView: View {
    var body: some View {
        NavigationView {
            SettingsView()
                .navigationTitle("Settings")
        }
    }
}

fileprivate struct SettingsView: View {
    @AppStorage(StorageKey.useBingeEpisodePicker.rawValue)
    private var useBingeEpisodePicker = false

    var body: some View {
        Form {
            Toggle("Use binge episode picker", isOn: $useBingeEpisodePicker)
        }
    }
}

class SettingsRootView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRootView()
    }
}
