import Swifter
import Foundation

class FakeServer {
    func setup() {
        let server = HttpServer()
        let port = ProcessInfo.processInfo.environment["PORT"] ?? "8080"
        try? server.start(UInt16(port) ?? 8080, forceIPv4: false, priority: .userInitiated)
    }
}
