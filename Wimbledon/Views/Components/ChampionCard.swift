//
//  ChampionCard.swift
//  Celda del listado, estilo "Results" de la app oficial de Wimbledon:
//  encabezado (cuadro + pista / Final + fecha), fila del campeón resaltada
//  en verde con check, fila del finalista y "Ver detalle →".
//

import SwiftUI

struct ChampionCard: View {
    let item: ItemModel

    var body: some View {
        VStack(spacing: 0) {
            // ── Encabezado: imagen (SF Symbol) + nombre del cuadro + subtítulo
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WimbledonTheme.green)
                        Text(item.category.rawValue)
                            .font(WimbledonFont.medium(15))
                            .foregroundStyle(.black.opacity(0.8))
                    }
                    Text(item.court)
                        .font(WimbledonFont.regular(13))
                        .foregroundStyle(WimbledonTheme.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Final")
                        .font(WimbledonFont.medium(15))
                        .foregroundStyle(.black.opacity(0.8))
                    Text(item.shortDate)
                        .font(WimbledonFont.regular(13))
                        .foregroundStyle(WimbledonTheme.secondaryText)
                }
            }
            .padding(16)

            // ── Campeón (fila verde con check)
            PlayerScoreRow(
                flag: item.flag,
                name: item.shortName,
                cells: item.sets.map { GameCell(games: $0.champion, tiebreak: $0.championTiebreak, wonSet: $0.championWon) },
                isWinner: true
            )

            Divider()

            // ── Finalista
            PlayerScoreRow(
                flag: item.opponentFlag,
                name: item.opponentShortName,
                cells: item.sets.map { GameCell(games: $0.opponent, tiebreak: $0.opponentTiebreak, wonSet: !$0.championWon) },
                isWinner: false
            )

            Divider()

            // ── Pie: Ver detalle →
            HStack(spacing: 10) {
                Spacer()
                Text("Ver detalle")
                    .font(WimbledonFont.semibold(15))
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .regular))
            }
            .foregroundStyle(WimbledonTheme.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(WimbledonTheme.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.black.opacity(0.12), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Piezas internas

private struct GameCell {
    let games: Int
    let tiebreak: Int?
    let wonSet: Bool
}

private struct PlayerScoreRow: View {
    let flag: String
    let name: String
    let cells: [GameCell]
    let isWinner: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(flag)
                .font(.system(size: 20))

            Text(name)
                .font(isWinner ? WimbledonFont.semibold(16) : WimbledonFont.medium(16))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            // Sets: el número del set ganado va en negrita; tie-break en pequeño
            HStack(spacing: 0) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    HStack(alignment: .top, spacing: 1) {
                        Text(String(cell.games))
                            .font(cell.wonSet ? WimbledonFont.bold(17) : WimbledonFont.regular(17))
                        if let tiebreak = cell.tiebreak {
                            Text(String(tiebreak))
                                .font(WimbledonFont.medium(10))
                        }
                    }
                    .foregroundStyle(.black)
                    .frame(width: 28, alignment: .leading)
                }
            }

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(WimbledonTheme.green)
                .opacity(isWinner ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(isWinner ? WimbledonTheme.green.opacity(0.14) : WimbledonTheme.white)
    }
}
