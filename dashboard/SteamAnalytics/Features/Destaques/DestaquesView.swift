// Features/Destaques/DestaquesView.swift
// Rankings de jogos (top 10), no espírito da página "Piores casos" do painel de referência.
import SwiftUI
import Charts

struct ModeloDestaques {
    let kpis: [KPI]
    let elegiveis: Int
    let melhores: [ItemGrafico]
    let piores: [ItemGrafico]
    let maisDonos: [ItemGrafico]
    let maisAvaliados: [ItemGrafico]

    /// Os 10 primeiros pela medida; empate desfeito pelo total de avaliações.
    static func top(_ jogos: [Jogo], por medida: (Jogo) -> Double, decrescente: Bool = true) -> [Jogo] {
        let ordenados = jogos.sorted { a, b in
            let ma = medida(a), mb = medida(b)
            if ma != mb { return decrescente ? ma > mb : ma < mb }
            return a.totalAvaliacoes > b.totalAvaliacoes
        }
        return Array(ordenados.prefix(10))
    }

    init(_ r: Recorte, minimo: Int) {
        let candidatos = r.base.filter { $0.totalAvaliacoes >= minimo }
        elegiveis = candidatos.count

        let topMelhores = Self.top(candidatos, por: \.pctPositivas)
        let topPiores = Self.top(candidatos, por: \.pctPositivas, decrescente: false)
        let topDonos = Self.top(r.catalogo, por: \.donosMedio)
        let topAvaliados = Self.top(r.catalogo, por: { Double($0.totalAvaliacoes) })

        melhores = topMelhores.map { ItemGrafico(rotulo: $0.nome, valor: $0.pctPositivas, cor: Paleta.cor(.positiva)) }
        piores = topPiores.map { ItemGrafico(rotulo: $0.nome, valor: $0.pctPositivas, cor: Paleta.cor(.negativa)) }
        maisDonos = topDonos.map { ItemGrafico(rotulo: $0.nome, valor: $0.donosMedio, cor: $0.gratuito ? Paleta.menor : Paleta.maior) }
        maisAvaliados = topAvaliados.map { ItemGrafico(rotulo: $0.nome, valor: Double($0.totalAvaliacoes), cor: Paleta.maior) }

        let gratuitosTopo = topDonos.filter(\.gratuito).count
        kpis = [
            KPI(titulo: "Mais bem avaliado", valor: topMelhores.first?.nome ?? "—", icone: "star.fill",
                detalhe: "% positivas", detalheValor: Fmt.pct(talvez: topMelhores.first?.pctPositivas),
                cor: Paleta.cor(.positiva)),
            KPI(titulo: "Pior avaliado", valor: topPiores.first?.nome ?? "—", icone: "hand.thumbsdown.fill",
                detalhe: "% positivas", detalheValor: Fmt.pct(talvez: topPiores.first?.pctPositivas),
                cor: Paleta.cor(.negativa)),
            KPI(titulo: "Mais donos", valor: topDonos.first?.nome ?? "—", icone: "person.3.fill",
                detalhe: "Donos (est.)", detalheValor: topDonos.first.map { Fmt.compacto($0.donosMedio) } ?? "—"),
            KPI(titulo: "Gratuitos no top 10 de donos", valor: "\(gratuitosTopo) de \(topDonos.count)", icone: "gift.fill",
                detalhe: "Gratuitos no catálogo", detalheValor: Fmt.pct(talvez: Estat.pct(r.catalogo) { $0.gratuito }),
                cor: Paleta.menor),
            KPI(titulo: "Jogos nos rankings de nota", valor: Fmt.num(candidatos.count), icone: "list.number",
                detalhe: "Mínimo de avaliações", detalheValor: Fmt.num(minimo)),
        ]
    }
}

struct DestaquesView: View {
    let dash: Dashboard
    @State private var minimo = 10_000

    private static let opcoesMinimo = [1_000, 10_000, 50_000]

    var body: some View {
        let r = dash.recorte
        let m = ModeloDestaques(r, minimo: minimo)
//
//        PaginaDashboard(dash: dash, recorte: r, pagina: .destaques, kpis: m.kpis) {
//            Painel(titulo: "Os 10 mais bem avaliados",
//                   subtitulo: "% de avaliações positivas, entre jogos com pelo menos \(Fmt.num(minimo)) avaliações.") {
//                GraficoBarras(itens: m.melhores, horizontal: true, formato: { Fmt.pct($0) }, percentual: true)
//            }
//            Painel(titulo: "Os 10 menos bem avaliados",
//                   subtitulo: "% de avaliações positivas, com o mesmo mínimo de avaliações.") {
//                GraficoBarras(itens: m.piores, horizontal: true, formato: { Fmt.pct($0) }, percentual: true)
//            }
//            Painel(titulo: "Os 10 com mais donos",
//                   subtitulo: "Ponto médio da faixa do SteamSpy. Laranja = gratuito; azul = pago.") {
//                GraficoBarras(itens: m.maisDonos, horizontal: true, formato: { Fmt.compacto($0) })
//            }
//            Painel(titulo: "Os 10 mais avaliados",
//                   subtitulo: "Total de avaliações (positivas + negativas).") {
//                GraficoBarras(itens: m.maisAvaliados, horizontal: true, formato: { Fmt.compacto($0) })
//            }
//        }
//        .toolbar {
//            ToolbarItem {
//                Picker("Mínimo de avaliações", selection: $minimo) {
//                    ForEach(Self.opcoesMinimo, id: \.self) { Text("≥ \(Fmt.num($0))").tag($0) }
//                }
//                .pickerStyle(.segmented)
//            }
//        }
    }
}
