import Foundation
import TelegramBotSDK

struct Situation {
    let id: String
    let text: String
    let answers: [(answer: String, nextQuestionId: String)]
}

private func handle(context: Context, for situation: Situation) {
    var markup = InlineKeyboardMarkup()
    let buttons: [InlineKeyboardButton] = situation.answers.map { answer in
        var button = InlineKeyboardButton()
        button.text = answer.answer
        button.callbackData = answer.nextQuestionId
        return button
    }
    
    markup.inlineKeyboard = [buttons]
    context.respondAsync(situation.text, replyMarkup: markup)
}

let bot = TelegramBot(token: "1085354218:AAGE7e1zuHdDLqubM9fsg5D-yn4TYB8Qwhk")
let router = Router(bot: bot)
private var situations: [Situation] = []

router["start"] = { (context: Context) -> Bool in
    handle(context: context, for: situations[0])
    return true
}

bot.deleteWebhookSync()

while let update = bot.nextUpdateSync() {
    if let message = update.message,
        let from = message.from,
        let username = from.username,
        situations.isEmpty {
        //load user scenario
        situations = [
            Situation(id: "first", text: "First situation", answers: [(answer: "answer 1", nextQuestionId: "second"),
                                                                      (answer: "answer 2", nextQuestionId: "third"),
                                                                      (answer: "answer 3", nextQuestionId: "fourth")]),
            Situation(id: "second", text: "Second situation", answers: [(answer: "answer 1", nextQuestionId: "third"),
                                                                        (answer: "answer 2", nextQuestionId: "fourth"),
                                                                        (answer: "answer 3", nextQuestionId: "first")]),
            Situation(id: "third", text: "Third situation", answers: [(answer: "answer 1", nextQuestionId: "fourth"),
                                                                      (answer: "answer 2", nextQuestionId: "first"),
                                                                      (answer: "answer 3", nextQuestionId: "second")]),
            Situation(id: "fourth", text: "Fourth situation", answers: [(answer: "answer 1", nextQuestionId: "first"),
                                                                        (answer: "answer 2", nextQuestionId: "second"),
                                                                        (answer: "answer 3", nextQuestionId: "third")])
        ]
        for situation in situations {
            router[.callback_query(data: situation.id)] = { (context: Context) -> Bool in
                handle(context: context, for: situation)
                return true
            }
        }
    }
    try router.process(update: update)
}

fatalError("Server stopped due to error: \(bot.lastError)")
