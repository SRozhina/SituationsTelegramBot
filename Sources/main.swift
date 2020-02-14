import Foundation
import TelegramBotSDK
import Swifter

let server = HttpServer()
let port = ProcessInfo.processInfo.environment["PORT"] ?? "8080"
try? server.start(UInt16(port) ?? 8080, forceIPv4: false, priority: .userInitiated)

print("starting the bot...")

let token = "1085354218:AAGE7e1zuHdDLqubM9fsg5D-yn4TYB8Qwhk"
let bot = TelegramBot(token: token)
let router = Router(bot: bot)
let controller = Controller(router: router)

bot.deleteWebhookSync()

print("the bot has started.")

while let update = bot.nextUpdateSync() {
    try? controller.handle(update: update)
}

fatalError("Server stopped due to error: \(bot.lastError)")
