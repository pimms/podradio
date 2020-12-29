import Foundation

extension URL {
    var withHttps: URL? {
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)
        comps?.scheme = "https"
        return comps?.url
    }
}
