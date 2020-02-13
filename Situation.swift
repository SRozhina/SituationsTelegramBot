struct Situation: Codable {
    struct Action: Codable {
        let text: String
        let nextSituationId: String
    }
    
    let id: String
    let text: String
    let actions: [Action]
}
