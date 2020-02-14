import Foundation
import TelegramBotSDK

var inputStream: InputStream!
var outputStream: OutputStream!

func connect() {
    var readStream:  Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?

    let port = UInt32(ProcessInfo.processInfo.environment["PORT"] ?? "443") ?? 8080
    
    CFStreamCreatePairWithSocketToHost(nil,
                                       "0.0.0.0" as CFString,
                                       port,
                                       &readStream,
                                       &writeStream)

    inputStream = readStream!.takeRetainedValue()
    outputStream = writeStream!.takeRetainedValue()

    inputStream.schedule(in: .current, forMode: .common)
    outputStream.schedule(in: .current, forMode: .common)

    inputStream.open()
    outputStream.open()
}

connect()

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
