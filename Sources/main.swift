import Foundation
import TelegramBotSDK

let server = FakeServer()
server.setup()

let token = "1085354218:AAGE7e1zuHdDLqubM9fsg5D-yn4TYB8Qwhk"
let bot = TelegramBot(token: token)
let controller = Controller(bot: bot)

bot.deleteWebhookSync()

while let update = bot.nextUpdateSync() {
    try? controller.handle(update: update)
}

fatalError("Server stopped due to error: \(bot.lastError)")
