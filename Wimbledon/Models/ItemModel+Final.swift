
import Foundation

/// Un set de la final, visto desde el campeón y desde el rival.
struct SetScore: Hashable {
    let champion: Int
    let opponent: Int
    let championTiebreak: Int?
    let opponentTiebreak: Int?

    var championWon: Bool { champion > opponent }
}

extension ItemModel {

    /// "6-7(7), 7-6(2), 6-3, 6-4" → 4 sets con sus tie-breaks.
    /// En la notación oficial, el número entre paréntesis son los puntos de quien
    /// PERDIÓ el tie-break; el ganador tiene 7, o 2 más si se pasó de 6.
    var sets: [SetScore] {
        score.components(separatedBy: ",").compactMap { raw in
            let part = raw.trimmingCharacters(in: .whitespaces)
            var gamesPart = part
            var loserTiebreak: Int? = nil

            if let open = part.firstIndex(of: "("), let close = part.firstIndex(of: ")") {
                loserTiebreak = Int(part[part.index(after: open)..<close])
                gamesPart = String(part[..<open])
            }

            let games = gamesPart.split(separator: "-").compactMap { Int($0) }
            guard games.count == 2 else { return nil }
            let c = games[0], o = games[1]

            guard let loserTB = loserTiebreak else {
                return SetScore(champion: c, opponent: o, championTiebreak: nil, opponentTiebreak: nil)
            }
            let winnerTB = max(7, loserTB + 2)
            return c > o
                ? SetScore(champion: c, opponent: o, championTiebreak: winnerTB, opponentTiebreak: loserTB)
                : SetScore(champion: c, opponent: o, championTiebreak: loserTB, opponentTiebreak: winnerTB)
        }
    }

    /// "Alexander Zverev (Alemania)" → "Alexander Zverev"
    var opponentName: String {
        finalOpponent.components(separatedBy: " (").first ?? finalOpponent
    }

    /// "Alexander Zverev (Alemania)" → "Alemania"
    var opponentCountry: String {
        guard let open = finalOpponent.firstIndex(of: "("),
              let close = finalOpponent.firstIndex(of: ")") else { return "" }
        return String(finalOpponent[finalOpponent.index(after: open)..<close])
    }

    var opponentFlag: String { Self.flags[opponentCountry] ?? "🏳️" }

    /// "Jannik Sinner" → "J. Sinner" (como en la app oficial)
    var shortName: String { Self.abbreviate(name) }
    var opponentShortName: String { Self.abbreviate(opponentName) }

    /// "12 de julio de 2026" → "12 JUL 2026"
    var shortDate: String {
        let parts = finalDate.components(separatedBy: " de ")
        guard parts.count == 3 else { return finalDate }
        return "\(parts[0]) \(parts[1].prefix(3).uppercased()) \(parts[2])"
    }

    // MARK: - Ayudantes
    private static func abbreviate(_ fullName: String) -> String {
        let parts = fullName.split(separator: " ")
        guard parts.count > 1, let initial = parts.first?.first else { return fullName }
        return "\(initial). \(parts.dropFirst().joined(separator: " "))"
    }

    private static let flags: [String: String] = [
        "Alemania": "🇩🇪",
        "Australia": "🇦🇺",
        "España": "🇪🇸",
        "Estados Unidos": "🇺🇸",
        "Italia": "🇮🇹",
        "República Checa": "🇨🇿",
        "Serbia": "🇷🇸",
        "Túnez": "🇹🇳"
    ]
}
