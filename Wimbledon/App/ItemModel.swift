//
//  ItemModel.swift
//  Modelo de cada elemento del listado: un campeón individual de Wimbledon.
//  Es un STRUCT (tipo valor) que conforma Identifiable (para List/ForEach)
//  y Hashable (para navigationDestination(for:)).
//

import Foundation

enum ChampionshipCategory: String, CaseIterable, Hashable {
    case gentlemen = "Individual Caballeros"   // "Gentlemen's Singles"
    case ladies    = "Individual Damas"        // "Ladies' Singles"

    var shortName: String {
        switch self {
        case .gentlemen: return "Caballeros"
        case .ladies:    return "Damas"
        }
    }
}

struct ItemModel: Identifiable, Hashable {
    let id = UUID()
    let name: String                   // Campeón/a
    let year: Int                      // Edición
    let category: ChampionshipCategory
    let country: String
    let flag: String
    let finalOpponent: String          // Rival en la final
    let score: String                  // Marcador de la final
    let finalDate: String              // Fecha de la final
    let wimbledonTitles: Int           // Títulos de Wimbledon tras esa final
    let court: String                  // Pista de la final
    let highlight: String              // Dato histórico

    /// SF Symbol de la celda y del hero del detalle.
    var symbol: String { "trophy.fill" }

    /// Subtítulo de la celda del listado.
    var subtitle: String { "\(category.rawValue) · \(String(year))" }
}
