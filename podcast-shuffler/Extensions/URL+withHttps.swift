import Foundation

extension URL {
    var withHttps: URL? {
        if self.scheme == "https" {
            return self
        }

        var comps = URLComponents(url: self, resolvingAgainstBaseURL: true)
        comps?.scheme = "https"
        return comps?.url
    }
}
