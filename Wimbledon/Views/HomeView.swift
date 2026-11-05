import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @Namespace private var tabNamespace

    private let chipGray = Color.black.opacity(0.06)
    private let pageBackground = Color(red: 0.965, green: 0.969, blue: 0.976)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        tabs
                        searchRow
                        yearChips

                        LazyVStack(spacing: 12) {
                            if viewModel.filteredItems.isEmpty {
                                ContentUnavailableView.search(text: viewModel.searchText)
                                    .padding(.top, 32)
                            } else {
                                ForEach(viewModel.filteredItems) { item in
                                    NavigationLink(value: item) {
                                        ChampionCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .background(pageBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ItemModel.self) { item in
                DetailView(item: item)
            }
        }
    }

    // MARK: - Encabezado fijo: título + logo
    private var header: some View {
        HStack(alignment: .center) {
            Text("Orden de juego")
                .font(WimbledonFont.bold(20))
                .foregroundStyle(.black)
            Spacer()
            WimbledonLogoView(size: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 14)
        .background(pageBackground)
    }

    // MARK: - Pestañas con subrayado verde
    private var tabs: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(ChampionFilter.allCases) { filter in
                    let isSelected = viewModel.selectedFilter == filter
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(filter.rawValue)
                                .font(isSelected ? WimbledonFont.semibold(15) : WimbledonFont.medium(15))
                                .foregroundStyle(isSelected ? WimbledonTheme.green : Color.black.opacity(0.5))
                                .padding(.horizontal, 14)
                            ZStack {
                                Rectangle().fill(Color.clear).frame(height: 2.5)
                                if isSelected {
                                    Rectangle()
                                        .fill(WimbledonTheme.green)
                                        .frame(height: 2.5)
                                        .matchedGeometryEffect(id: "underline", in: tabNamespace)
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
            .padding(.top, 4)

            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
        }
    }

    // Buscador + logout
    private var searchRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.6))
                TextField("Buscar campeón, país o año", text: $viewModel.searchText)
                    .font(WimbledonFont.medium(14))
                    .foregroundStyle(.black)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.black.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(chipGray)
            )

            Button {
                authViewModel.logout()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(chipGray))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cerrar sesión")
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // Chips de años
    private var yearChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                YearChip(title: "Todos",
                         subtitle: "\(viewModel.years.count) ED.",
                         isSelected: viewModel.selectedYear == nil,
                         chipGray: chipGray) {
                    withAnimation(.easeInOut(duration: 0.25)) { viewModel.selectedYear = nil }
                }

                ForEach(viewModel.years, id: \.self) { year in
                    YearChip(title: String(year),
                             subtitle: "\(HomeViewModel.edition(of: year)).ª ED.",
                             isSelected: viewModel.selectedYear == year,
                             chipGray: chipGray) {
                        withAnimation(.easeInOut(duration: 0.25)) { viewModel.selectedYear = year }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
    }
}

// Chip de año
private struct YearChip: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let chipGray: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(title)
                    .font(WimbledonFont.semibold(14))
                Text(subtitle)
                    .font(WimbledonFont.medium(9))
            }
            .foregroundStyle(isSelected ? WimbledonTheme.white : Color.black.opacity(0.55))
            .frame(width: 56, height: 54)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? WimbledonTheme.green : chipGray)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.signIn(.demo)
    return HomeView().environmentObject(auth)
}
