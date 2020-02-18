import Foundation
import TelegramBotSDK

class Controller {
    private let router: Router
    private var situations: [String: [Situation]] = [:]
    
    init(router: Router) {
        self.router = router
        
        router["start"] = { [weak self] context in
            guard let self = self,
                let username = context.message?.from?.username else { return true }
            let currentSituations = self.getSituations(for: context.args.scanWord() ?? username)
            self.situations[username] = currentSituations
            for situation in currentSituations {
                router[.callback_query(data: situation.id)] = { [weak self] context in
                    guard let self = self else { return true }
                    self.handle(context: context, for: situation)
                    return true
                }
            }
            self.handle(context: context, for: currentSituations[0])
            return true
        }
    }
    
    func handle(update: Update) throws {
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
        guard let fileType = Resources().children.first(where: { $0.filename.lowercased().contains(userName.lowercased()) }),
            let file = fileType as? File,
            let data = file.contents,
            let situations = try? JSONDecoder().decode([Situation].self, from: data) else {
            assertionFailure("don't have file or couldn't parse")
            return []
        }
        return situations
    }
}
