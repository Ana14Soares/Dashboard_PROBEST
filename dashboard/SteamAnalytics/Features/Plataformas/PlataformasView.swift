// Features/Plataformas/PlataformasView.swift
// Dados para falar de H2 (multiplataforma × bem avaliado) e H5 (conquistas × donos).
import SwiftUI
import Charts

struct ModeloPlataformas {
    let kpis: [KPI]
    let porPlataformas: [ItemGrafico]     // % bem avaliados com 1, 2 e 3 sistemas
    let contingencia: [[Int]]             // [uma, multi] × [< 80%, ≥ 80%]
    let donosConquistas: [ItemGrafico]    // % acima de 20 mil donos, sem × com
    let alcanceConquistas: [ItemSerie]    // % de cada grupo por faixa de donos

    init(_ r: Recorte) {
        let cat = r.catalogo, base = r.base

        porPlataformas = ItemGrafico.destacandoExtremos((1...3).compactMap { n -> ItemGrafico? in
            let grupo = base.filter { $0.plataformas.count == n }
            guard let v = Estat.pct(grupo, onde: { $0.pctPositivas >= 80 }) else { return nil }
            return ItemGrafico(rotulo: n == 1 ? "1 sistema" : "\(n) sistemas", valor: v)
        })

        func conta(multi: Bool, bem: Bool) -> Int {
            base.filter { $0.multiplataforma == multi && ($0.pctPositivas >= 80) == bem }.count
        }
        contingencia = [[conta(multi: false, bem: false), conta(multi: false, bem: true)],
                        [conta(multi: true, bem: false), conta(multi: true, bem: true)]]

        let bemMulti = Estat.pct(base.filter(\.multiplataforma)) { $0.pctPositivas >= 80 }
        let bemUma = Estat.pct(base.filter { !$0.multiplataforma }) { $0.pctPositivas >= 80 }
        var difPlataforma: Double? = nil
        if let a = bemMulti, let b = bemUma { difPlataforma = a - b }

        let com = cat.filter(\.temConquistas)
        let sem = cat.filter { !$0.temConquistas }
        let acimaCom = Estat.pct(com) { $0.acimaVinteMil }
        let acimaSem = Estat.pct(sem) { $0.acimaVinteMil }

        var itensDonos: [ItemGrafico] = []
        if let v = acimaSem { itensDonos.append(ItemGrafico(rotulo: "Sem conquistas", valor: v)) }
        if let v = acimaCom { itensDonos.append(ItemGrafico(rotulo: "Com conquistas", valor: v)) }
        donosConquistas = ItemGrafico.destacandoExtremos(itensDonos)

        var serie: [ItemSerie] = []
        for a in Alcance.allCases {
            if let v = Estat.pct(sem, onde: { $0.alcance == a }) {
                serie.append(ItemSerie(categoria: a.rawValue, serie: "Sem conquistas", valor: v))
            }
            if let v = Estat.pct(com, onde: { $0.alcance == a }) {
                serie.append(ItemSerie(categoria: a.rawValue, serie: "Com conquistas", valor: v))
            }
        }
        alcanceConquistas = serie

        kpis = [
            KPI(titulo: "Multiplataforma", valor: Fmt.pct(talvez: Estat.pct(cat) { $0.multiplataforma }),
                icone: "desktopcomputer",
                detalhe: "Windows + Mac + Linux",
                detalheValor: Fmt.pct(talvez: Estat.pct(cat) { $0.plataformas.count == 3 })),
            KPI(titulo: "Bem avaliados — multi", valor: Fmt.pct(talvez: bemMulti), icone: "checkmark.seal.fill",
                detalhe: "Uma plataforma", detalheValor: Fmt.pct(talvez: bemUma), cor: Paleta.maior),
            KPI(titulo: "Com conquistas", valor: Fmt.pct(talvez: Estat.pct(cat) { $0.temConquistas }),
                icone: "trophy.fill",
                detalhe: "Mediana de conquistas",
                detalheValor: Estat.mediana(com.map { Double($0.conquistas) }).map { Fmt.num(Int($0)) } ?? "—"),
            KPI(titulo: "Mais de 20 mil donos (com conquistas)", valor: Fmt.pct(talvez: acimaCom), icone: "person.3.fill",
                detalhe: "Sem conquistas", detalheValor: Fmt.pct(talvez: acimaSem), cor: Paleta.maior),
        ]
    }
}

struct PlataformasView: View {
    let dash: Dashboard

    var body: some View {
        let r = dash.recorte
        let m = ModeloPlataformas(r)

        PaginaDashboard(dash: dash, recorte: r, pagina: .plataformas, kpis: m.kpis) {
            Painel(titulo: "Jogos bem avaliados (≥ 80%) por número de sistemas",
                   subtitulo: "Windows, Mac e Linux. Base: jogos com ≥ \(r.minAvaliacoes) avaliações.") {
                GraficoBarras(itens: m.porPlataformas, formato: { Fmt.pct($0) }, percentual: true)
            }

            Painel(titulo: "Plataformas × avaliação",
                   subtitulo: "Contagem de jogos da base; percentual dentro de cada linha. Em azul, a parte bem avaliada.") {
                TabelaContingencia(linhas: ["Uma plataforma", "Multiplataforma"],
                                   colunas: ["< 80% positivas", "≥ 80% positivas"],
                                   valores: m.contingencia)
                    .padding(.vertical, 8)
            }

            Painel(titulo: "Jogos com mais de 20 mil donos: sem × com conquistas",
                   subtitulo: "Catálogo inteiro. A mediana de donos é a mesma nos dois grupos (a menor faixa), por isso a comparação usa este percentual.") {
                GraficoBarras(itens: m.donosConquistas, horizontal: true, formato: { Fmt.pct($0) }, percentual: true)
            }

            Painel(titulo: "Distribuição por faixa de donos: sem × com conquistas",
                   subtitulo: "Percentual de cada grupo em cada faixa (cada cor soma 100%).") {
                GraficoAgrupado(itens: m.alcanceConquistas,
                                series: ["Sem conquistas", "Com conquistas"],
                                cores: [Paleta.menor, Paleta.maior],
                                horizontal: true)
            }
        }
    }
}
