import Foundation
import TelegramBotSDK

let token = "1085354218:AAGE7e1zuHdDLqubM9fsg5D-yn4TYB8Qwhk"
let bot = TelegramBot(token: token)
let router = Router(bot: bot)
let controller = Controller(router: router)

bot.deleteWebhookSync()

while let update = bot.nextUpdateSync() {
    try? controller.handle(update: update)
}

func resolvePort() -> Int {
    let defaultPort = 8080
    
    if let requestedPort = ProcessInfo.processInfo.environment["PORT"],
        let port = Int(requestedPort) {
        return port
    }
    return defaultPort
}

fatalError("Server stopped due to error: \(bot.lastError)")
