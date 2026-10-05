// App/RootView.swift
import SwiftUI

/// As páginas do painel. Cada uma junta os dados de que a equipe precisa
/// para falar de uma ou duas hipóteses, sem mostrar o teste em si.
enum Pagina: String, CaseIterable, Identifiable, Hashable {
    case visaoGeral   = "Visão geral"
    case preco        = "Preço e gratuidade"
    case plataformas  = "Plataformas e conquistas"
//    case generos      = "Gêneros"
//    case linhaDoTempo = "Linha do tempo"
//    case destaques    = "Destaques"
//    case explorar     = "Explorar jogos"

    var id: String { rawValue }

    var icone: String {
        switch self {
        case .visaoGeral:   "square.grid.2x2.fill"
        case .preco:        "sterlingsign.circle.fill"
        case .plataformas:  "desktopcomputer"
//        case .generos:      "theatermasks.fill"
//        case .linhaDoTempo: "calendar"
//        case .destaques:    "star.fill"
//        case .explorar:     "magnifyingglass"
        }
    }

    /// Subtítulo do cabeçalho: a pergunta que a página ajuda a responder.
    var pergunta: String {
        switch self {
        case .visaoGeral:   "Como é o catálogo da Steam e como os jogos são avaliados?"
        case .preco:        "Jogos gratuitos e jogos mais caros são avaliados de forma diferente?"
        case .plataformas:  "Rodar em mais sistemas e ter conquistas acompanha avaliação e alcance maiores?"
//        case .generos:      "A avaliação muda de um gênero para outro?"
//        case .linhaDoTempo: "A avaliação mudou com a explosão de lançamentos a partir de 2014?"
//        case .destaques:    "Quais jogos puxam os extremos de avaliação e de público no recorte?"
//        case .explorar:     "Busque e compare jogos do recorte atual."
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        switch app.estado {
        case .carregando:
            ProgressView("Carregando o catálogo…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .falha(let msg):
            ContentUnavailableView("Não foi possível carregar",
                                   systemImage: "exclamationmark.triangle",
                                   description: Text(msg))
        case .pronto(let dash):
            PainelPrincipal(dash: dash)
        }
    }
}

private struct PainelPrincipal: View {
    @Bindable var dash: Dashboard
    @State private var pagina: Pagina? = .visaoGeral

    var body: some View {
        NavigationSplitView {
            BarraLateral(pagina: $pagina, filtro: $dash.filtro)
                .navigationSplitViewColumnWidth(min: 240, ideal: 260, max: 300)
        } detail: {
            NavigationStack {
                conteudo(pagina ?? .visaoGeral)
                    .larguraAdaptativa()
            }
        }
        #if os(macOS)
        .frame(minWidth: 1100, minHeight: 720)
        #endif
    }

    @ViewBuilder
    private func conteudo(_ p: Pagina) -> some View {
        switch p {
        case .visaoGeral:   VisaoGeralView(dash: dash)
        case .preco:        PrecoView(dash: dash)
        case .plataformas:  PlataformasView(dash: dash)
//        case .generos:      GenerosView(dash: dash)
//        case .linhaDoTempo: LinhaDoTempoView(dash: dash)
//        case .destaques:    DestaquesView(dash: dash)
//        case .explorar:     ExplorarView(dash: dash)
        }
    }
}
