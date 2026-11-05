//
//  HomeViewModel.swift
//  Expone los campeones y calcula el filtrado de forma reactiva (Combine),
//  fuera del body de la vista: texto + cuadro (tabs) + año (chips).
//

import Foundation
import Combine

enum ChampionFilter: String, CaseIterable, Identifiable {
    case all       = "Todos"
    case gentlemen = "Caballeros"
    case ladies    = "Damas"

    var id: String { rawValue }
}

@MainActor
final class HomeViewModel: ObservableObject {
    /// Fuente de datos: 10 campeones reales hardcodeados (2022–2026).
    @Published var items: [ItemModel] = ItemModel.champions

    /// Texto del buscador (TextField).
    @Published var searchText = ""

    /// Pestaña seleccionada (Todos / Caballeros / Damas).
    @Published var selectedFilter: ChampionFilter = .all

    /// Año seleccionado en los chips (nil = todos).
    @Published var selectedYear: Int? = nil

    /// Resultado ya filtrado: la vista solo lo lee.
    @Published private(set) var filteredItems: [ItemModel] = []

    /// Años disponibles, del más reciente al más antiguo.
    var years: [Int] {
        Array(Set(items.map(\.year))).sorted(by: >)
    }

    /// Número de edición de The Championships.
    /// Válido desde 2021 (2020 se canceló): 2026 → 139.ª edición.
    static func edition(of year: Int) -> Int { year - 1887 }

    init() {
        filteredItems = items

        Publishers.CombineLatest4(
            $items,
            $searchText
                .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
                .removeDuplicates(),
            $selectedFilter,
            $selectedYear
        )
        .map { items, text, filter, year in
            HomeViewModel.filter(items, text: text, filter: filter, year: year)
        }
        .assign(to: &$filteredItems)
    }

    private nonisolated static func filter(_ items: [ItemModel],
                                           text: String,
                                           filter: ChampionFilter,
                                           year: Int?) -> [ItemModel] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return items.filter { item in
            // Pestaña
            switch filter {
            case .all:       break
            case .gentlemen: if item.category != .gentlemen { return false }
            case .ladies:    if item.category != .ladies { return false }
            }
            // Año
            if let year, item.year != year { return false }
            // Texto (ignora mayúsculas y tildes: "swiatek" encuentra "Świątek")
            guard !query.isEmpty else { return true }
            return item.name.localizedStandardContains(query)
                || item.country.localizedStandardContains(query)
                || item.finalOpponent.localizedStandardContains(query)
                || String(item.year).contains(query)
        }
    }
}
