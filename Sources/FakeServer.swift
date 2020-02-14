import Swifter
import Foundation

class FakeServer {
    private let server: HttpServerIO
    
    init(server: HttpServerIO = HttpServer()) {
        self.server = server
    }
    
    func setup() {
        let port = ProcessInfo.processInfo.environment["PORT"] ?? "8080"
        try? server.start(UInt16(port) ?? 8080, forceIPv4: false, priority: .userInitiated)
    }
}
