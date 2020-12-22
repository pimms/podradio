import Foundation

class Log {
    enum Level: Int {
        case debug
        case info
        case warn
        case error
    }

    static var threshold: Level = .debug

    private let owner: String

    init<T>(_ owner: T.Type) {
        self.owner = String(describing: owner)
    }

    init(_ owner: Any) {
        self.owner = String(describing: type(of: owner))
    }

    func log(_ message: @autoclosure () -> String, _ severity: Level = .info) {
        if severity.rawValue >= Self.threshold.rawValue {
            print("[\(owner)][\(severity)] \(message())")
        }
    }

    func debug(_ message: @autoclosure () -> String) {
        log(message(), .debug)
    }

    func info(_ message: @autoclosure () -> String) {
        log(message(), .info)
    }

    func warn(_ message: @autoclosure () -> String) {
        log(message(), .warn)
    }

    func error(_ message: @autoclosure () -> String) {
        log(message(), .error)
    }
}
