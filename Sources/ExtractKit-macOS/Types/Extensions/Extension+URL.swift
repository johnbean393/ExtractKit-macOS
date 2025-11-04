import Foundation

public extension URL {
    
    /// A Boolean value indicating whether the URL uses the http or https scheme.
    var isWebURL: Bool {
        guard let scheme = self.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }
    
}
