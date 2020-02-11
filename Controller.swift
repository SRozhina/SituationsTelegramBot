import Foundation
import TelegramBotSDK

class Controller {
    private let router: Router
    private var situations: [Situation] = []
    
    init(router: Router) {
        self.router = router
        
        router["start"] = { [weak self] context in
            guard let self = self else { return true }
            self.handle(context: context, for: self.situations[0])
            return true
        }
    }
    
    func handle(update: Update) throws {
        if let message = update.message,
            let from = message.from,
            let username = from.username,
            situations.isEmpty {
            //load user scenario
            situations = getSituations()
            for situation in situations {
                router[.callback_query(data: situation.id)] = { [weak self] context in
                    guard let self = self else { return true }
                    self.handle(context: context, for: situation)
                    return true
                }
            }
        }
        try router.process(update: update)
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
    
    private func getSituations() -> [Situation] {
        return [
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
    }
}
