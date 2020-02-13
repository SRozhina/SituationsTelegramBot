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
            situations = getSituations(for: username)
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
        let buttons: [InlineKeyboardButton] = situation.actions.map { action in
            var button = InlineKeyboardButton()
            button.text = action.text
            button.callbackData = action.nextSituationId
            return button
        }
        
        markup.inlineKeyboard = [buttons]
        context.respondAsync(situation.text, replyMarkup: markup)
    }
    
    private func getSituations(for userName: String) -> [Situation] {
        guard let data = Resources.Sofiarozhina_Json().contents,
        let situations = try? JSONDecoder().decode([Situation].self, from: data) else {
            assertionFailure("don't have file or couldn't parse")
            return []
        }
        return situations
    }
}
