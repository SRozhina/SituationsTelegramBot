import Foundation
import TelegramBotSDK

class Controller {
    private var routers: [String: Router] = [:]
    private let bot: TelegramBot
    private var situations: [String: [Situation]] = [:]
    
    init(bot: TelegramBot) {
        self.bot = bot
        let router = Router(bot: bot)
        
        router["start"] = { [weak self] context in
            guard let self = self,
                let username = context.message?.from?.username else { return true }
            let currentSituations = self.getSituations(for: context.args.scanWord() ?? username)
            self.situations[username] = currentSituations
            let userRouter = Router(bot: bot)
            for situation in currentSituations {
                userRouter[.callback_query(data: situation.id)] = { [weak self] context in
                    guard let self = self else { return true }
                    self.handle(context: context, for: situation)
                    return true
                }
            }
            self.routers[username] = userRouter
            self.handle(context: context, for: currentSituations[0])
            return true
        }
        
        routers["main"] = router
    }
    
    func handle(update: Update) throws {
        if let username = update.callbackQuery?.from.username, let userRouter = routers[username] {
            try userRouter.process(update: update)
        } else {
            try routers["main"]?.process(update: update)
        }
    }
    
    private func handle(context: Context, for situation: Situation) {
        var markup = InlineKeyboardMarkup()
        let buttons: [InlineKeyboardButton] = situation.actions.map { action in
            var button = InlineKeyboardButton()
            button.text = action.text
            button.callbackData = action.nextSituationId
            return button
        }
        
        if buttons.isEmpty, let username = context.update.callbackQuery?.from.username {
            finishStory(for: username)
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
    
    private func finishStory(for username: String) {
        routers.removeValue(forKey: username) 
    }
}
