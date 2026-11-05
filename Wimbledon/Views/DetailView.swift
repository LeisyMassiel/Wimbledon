import SwiftUI

private enum DetailTab: String, CaseIterable, Identifiable {
    case summary = "Resumen"
    case history = "Historia"
    var id: String { rawValue }
}

struct DetailView: View {
    let item: ItemModel

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .summary
    @Namespace private var tabNamespace

    // Tonos tomados de la pantalla de detalle de la app oficial
    private let heroGreen = Color(red: 13/255, green: 51/255, blue: 32/255)     // verde oscuro del bloque
    private let ballYellow = Color(red: 214/255, green: 224/255, blue: 0/255)   // check "pelota de tenis"
    private let pageBackground = Color(red: 0.965, green: 0.969, blue: 0.976)

    /// Qué tan oscura es la capa verde sobre la foto (0.6 = se ve más la foto, 0.85 = casi nada)
    private let photoOverlayOpacity: Double = 0.75

    // MARK: - Datos calculados del marcador real
    private var championSets: Int { item.sets.filter(\.championWon).count }
    private var opponentSets: Int { item.sets.count - championSets }
    private var championGames: Int { item.sets.reduce(0) { $0 + $1.champion } }
    private var opponentGames: Int { item.sets.reduce(0) { $0 + $1.opponent } }
    private var championTiebreaks: Int { item.sets.filter { $0.championTiebreak != nil && $0.championWon }.count }
    private var opponentTiebreaks: Int { item.sets.filter { $0.championTiebreak != nil && !$0.championWon }.count }

    private var related: [ItemModel] {
        ItemModel.champions.filter { $0.id != item.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 0) {
                    hero
                    tabs

                    Group {
                        switch selectedTab {
                        case .summary: summary
                        case .history: history
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    relatedSection
                        .padding(.top, 32)
                }
            }
            .background(WimbledonTheme.white)
        }
        .background(pageBackground.ignoresSafeArea(edges: .top))
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Barra superior: ← y logo
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Volver")

            Spacer()

            WimbledonLogoView(size: 28)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(pageBackground)
    }

    // MARK: - Hero con foto de fondo
    private var hero: some View {
        VStack(spacing: 0) {
            // Imagen grande
            Image(systemName: item.symbol)
                .font(.system(size: 48, weight: .regular))
                .foregroundStyle(WimbledonTheme.white)
                .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
                .padding(.top, 22)

            VStack(spacing: 8) {
                Text("THE CHAMPIONSHIPS · \(String(item.year))")
                    .font(WimbledonFont.semibold(11))
                    .tracking(0.8)
                    .foregroundStyle(WimbledonTheme.white.opacity(0.9))

                Text("FINAL \(item.category.rawValue.uppercased())")
                    .font(WimbledonFont.bold(22))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(WimbledonTheme.white)

                Text("\(item.court)  •  Finalizado  -  \(item.shortDate)")
                    .font(WimbledonFont.regular(13))
                    .foregroundStyle(WimbledonTheme.white.opacity(0.9))
            }
            .padding(.top, 14)
            .padding(.horizontal, 16)

            // Jugadores
            HStack(alignment: .top, spacing: 12) {
                PlayerHeader(flag: item.flag, fullName: item.name, role: "Campeón", isLeading: true)
                PlayerHeader(flag: item.opponentFlag, fullName: item.opponentName, role: "Finalista", isLeading: false)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 20)

            // Marcador: campeón en verde Wimbledon, finalista transparente (deja ver la foto)
            HeroScoreRow(
                name: item.shortName,
                cells: item.sets.map { HeroCell(games: $0.champion, tiebreak: $0.championTiebreak, wonSet: $0.championWon) },
                isWinner: true,
                background: WimbledonTheme.green,
                checkColor: ballYellow,
                checkInner: heroGreen
            )
            HeroScoreRow(
                name: item.opponentShortName,
                cells: item.sets.map { HeroCell(games: $0.opponent, tiebreak: $0.opponentTiebreak, wonSet: !$0.championWon) },
                isWinner: false,
                background: .clear,
                checkColor: ballYellow,
                checkInner: heroGreen
            )
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background {
            // Foto "fondo" (Assets.xcassets) + capa verde oscura para que el texto se lea
            Image("fondo")
                .resizable()
                .scaledToFill()
                .overlay(heroGreen.opacity(photoOverlayOpacity))
        }
        .background(heroGreen)      // color de respaldo si la imagen no carga
        .clipped()
    }

    // MARK: - Pestañas
    private var tabs: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(DetailTab.allCases) { tab in
                    let isSelected = selectedTab == tab
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { selectedTab = tab }
                    } label: {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(isSelected ? WimbledonFont.semibold(15) : WimbledonFont.medium(15))
                                .foregroundStyle(isSelected ? WimbledonTheme.green : Color.black.opacity(0.5))
                                .padding(.horizontal, 14)
                            ZStack {
                                Rectangle().fill(Color.clear).frame(height: 2.5)
                                if isSelected {
                                    Rectangle()
                                        .fill(WimbledonTheme.green)
                                        .frame(height: 2.5)
                                        .matchedGeometryEffect(id: "detailUnderline", in: tabNamespace)
                                }
                            }
                        }
                        .fixedSize()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 6)
            .padding(.top, 18)

            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
        }
    }

    // MARK: - Pestaña Resumen
    private var summary: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Datos de la final")
                .font(WimbledonFont.semibold(18))
                .foregroundStyle(.black)
                .padding(.bottom, 10)

            HStack {
                Text(item.shortName)
                    .foregroundStyle(WimbledonTheme.purple)
                Spacer()
                Text(item.opponentShortName)
                    .foregroundStyle(.black)
            }
            .font(WimbledonFont.medium(11))
            .padding(.bottom, 2)

            StatRow(title: "Sets ganados", left: championSets, right: opponentSets)
            StatRow(title: "Juegos ganados", left: championGames, right: opponentGames)
            StatRow(title: "Tie-breaks ganados", left: championTiebreaks, right: opponentTiebreaks)

            Text("Ficha del campeón")
                .font(WimbledonFont.semibold(18))
                .foregroundStyle(.black)
                .padding(.top, 28)
                .padding(.bottom, 2)

            InfoRow(label: "Campeón", value: item.name)
            InfoRow(label: "País", value: "\(item.flag) \(item.country)")
            InfoRow(label: "Rival en la final", value: item.finalOpponent)
            InfoRow(label: "Marcador", value: item.score)
            InfoRow(label: "Fecha de la final", value: item.finalDate)
            InfoRow(label: "Pista", value: item.court)
            InfoRow(label: "Títulos en Wimbledon", value: String(item.wimbledonTitles))
        }
    }

    // MARK: - Pestaña Historia
    private var history: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATO HISTÓRICO")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .tracking(0.8)
                .foregroundStyle(WimbledonTheme.purple)

            Text(item.name)
                .font(WimbledonFont.bold(20))
                .foregroundStyle(.black)

            Text(item.highlight)
                .font(WimbledonFont.regular(14))
                .foregroundStyle(.black.opacity(0.8))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(item.category.rawValue) · \(item.finalDate)")
                .font(WimbledonFont.regular(12))
                .foregroundStyle(WimbledonTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Más campeones
    private var relatedSection: some View {
        VStack(spacing: 4) {
            Text("DESCUBRE MÁS")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .tracking(0.8)
                .foregroundStyle(WimbledonTheme.purple)

            Text("MÁS CAMPEONES")
                .font(WimbledonFont.bold(20))
                .foregroundStyle(.black)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(related) { other in
                        NavigationLink(value: other) {
                            ChampionCard(item: other)
                                .frame(width: 300)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .padding(.top, 18)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(pageBackground)
    }
}

// MARK: - Componentes internos

private struct PlayerHeader: View {
    let flag: String
    let fullName: String
    let role: String
    let isLeading: Bool

    private var firstName: String {
        fullName.split(separator: " ").first.map(String.init) ?? ""
    }
    private var lastName: String {
        fullName.split(separator: " ").dropFirst().joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: isLeading ? .leading : .trailing, spacing: 2) {
            ZStack(alignment: isLeading ? .bottomTrailing : .bottomLeading) {
                Circle()
                    .fill(WimbledonTheme.green)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "figure.tennis")
                            .font(.system(size: 24))
                            .foregroundStyle(WimbledonTheme.white)
                    )
                Text(flag)
                    .font(.system(size: 16))
                    .offset(x: isLeading ? 4 : -4, y: 3)
            }
            .padding(.bottom, 6)

            Text(firstName)
                .font(WimbledonFont.medium(11))
                .foregroundStyle(WimbledonTheme.white.opacity(0.85))
            Text(lastName)
                .font(WimbledonFont.semibold(19))
                .foregroundStyle(WimbledonTheme.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(role)
                .font(WimbledonFont.regular(10))
                .foregroundStyle(WimbledonTheme.white.opacity(0.7))
        }
        .multilineTextAlignment(isLeading ? .leading : .trailing)
        .frame(maxWidth: .infinity, alignment: isLeading ? .leading : .trailing)
    }
}

private struct HeroCell {
    let games: Int
    let tiebreak: Int?
    let wonSet: Bool
}

private struct HeroScoreRow: View {
    let name: String
    let cells: [HeroCell]
    let isWinner: Bool
    let background: Color
    let checkColor: Color
    let checkInner: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(WimbledonFont.semibold(14))
                .foregroundStyle(WimbledonTheme.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 6)

            HStack(spacing: 0) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    HStack(alignment: .top, spacing: 1) {
                        Text(String(cell.games))
                            .font(cell.wonSet ? WimbledonFont.semibold(15) : WimbledonFont.regular(15))
                        if let tiebreak = cell.tiebreak {
                            Text(String(tiebreak))
                                .font(WimbledonFont.medium(8))
                        }
                    }
                    .foregroundStyle(WimbledonTheme.white)
                    .frame(width: 23, alignment: .leading)
                }
            }

            Image(systemName: "checkmark.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(checkInner, checkColor)
                .font(.system(size: 14))
                .opacity(isWinner ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(background)
    }
}

private struct StatRow: View {
    let title: String
    let left: Int
    let right: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(left))
                    .font(WimbledonFont.bold(17))
                    .foregroundStyle(WimbledonTheme.purple)
                Spacer()
                Text(title)
                    .font(WimbledonFont.regular(12))
                    .foregroundStyle(WimbledonTheme.secondaryText)
                Spacer()
                Text(String(right))
                    .font(WimbledonFont.bold(17))
                    .foregroundStyle(.black)
            }

            GeometryReader { geo in
                let half = geo.size.width / 2
                let maxValue = CGFloat(max(left, right, 1))
                ZStack {
                    Rectangle()
                        .fill(WimbledonTheme.purple.opacity(0.12))
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(WimbledonTheme.purple)
                            .frame(width: half * CGFloat(left) / maxValue)
                        Spacer(minLength: 0)
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: half * CGFloat(right) / maxValue)
                    }
                }
            }
            .frame(height: 2.5)
        }
        .padding(.vertical, 10)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(label)
                    .font(WimbledonFont.regular(13))
                    .foregroundStyle(WimbledonTheme.secondaryText)
                Spacer(minLength: 12)
                Text(value)
                    .font(WimbledonFont.medium(13))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 11)
            Divider()
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(item: ItemModel.champions[0])
    }
}
