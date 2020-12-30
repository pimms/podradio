import Foundation
import UIKit

extension ProcessInfo {
    static var isiPad: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }

        return processInfo.isiOSAppOnMac || processInfo.isMacCatalystApp
    }
}
