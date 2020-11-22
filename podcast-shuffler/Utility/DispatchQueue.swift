import Foundation

extension DispatchQueue {
    static func syncOnMain(_ execute: () -> Void) {
        if Thread.isMainThread {
            execute()
        } else {
            DispatchQueue.main.sync {
                execute()
            }
        }
    }
}
