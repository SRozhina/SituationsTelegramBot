import Foundation
import TelegramBotSDK

let server = FakeServer()
server.setup()

let token = "1098709393:AAEbylV3dHU9zRbtpH6c2FklaNFdxsVzHIU"
let bot = TelegramBot(token: token)
let controller = Controller(bot: bot)

bot.deleteWebhookSync()

while let update = bot.nextUpdateSync() {
    try? controller.handle(update: update)
}

fatalError("Server stopped due to error: \(bot.lastError)")
