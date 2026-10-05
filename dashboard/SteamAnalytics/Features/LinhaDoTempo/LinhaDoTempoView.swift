// Features/LinhaDoTempo/LinhaDoTempoView.swift
// Dados para falar de H6 (avaliação ao longo dos anos).
import SwiftUI
import Charts

struct ModeloLinhaDoTempo {
    let kpis: [KPI]
    let porAno: [ResumoGrupo]           // mediana e Q1–Q3 por ano (rótulo = ano)
    let pisoEixo: Double                // início do eixo y, abaixo do menor Q1
    let periodos: [ResumoGrupo]
    let medianaGeral: Double?
    let composicao: [FatiaComposicao]   // faixas de avaliação por ano
    let catalogo: [ItemSerie]           // % gratuitos, multiplataforma e indie por ano

    init(_ r: Recorte, meta: Metadados) {
        let anos = Array(2006...meta.anoMax)
        let baseAno = Dictionary(grouping: r.base, by: \.ano)
        let catAno = Dictionary(grouping: r.catalogo, by: \.ano)
        medianaGeral = Estat.mediana(r.base.map(\.pctPositivas))

        let resumosAno = anos.compactMap { Estat.resumo(String($0), (baseAno[$0] ?? []).map(\.pctPositivas)) }
        porAno = resumosAno
        pisoEixo = max(0, ((resumosAno.map(\.q1).min() ?? 40) / 10).rounded(.down) * 10)

        let basePeriodo = Dictionary(grouping: r.base, by: \.periodo)
        let resumosPeriodo = Periodo.allCases.compactMap {
            Estat.resumo($0.rawValue, (basePeriodo[$0] ?? []).map(\.pctPositivas))
        }
        periodos = resumosPeriodo

        composicao = FatiaComposicao.de(anos.map { (String($0), baseAno[$0] ?? []) })

        var serie: [ItemSerie] = []
        for ano in anos {
            let jogos = catAno[ano] ?? []
            let rotulo = String(ano)
            if let v = Estat.pct(jogos, onde: { $0.gratuito }) {
                serie.append(ItemSerie(categoria: rotulo, serie: "Gratuitos", valor: v))
            }
            if let v = Estat.pct(jogos, onde: { $0.multiplataforma }) {
                serie.append(ItemSerie(categoria: rotulo, serie: "Multiplataforma", valor: v))
            }
            if let v = Estat.pct(jogos, onde: { $0.indie }) {
                serie.append(ItemSerie(categoria: rotulo, serie: "Indie", valor: v))
            }
        }
        catalogo = serie

        let n2013 = catAno[2013]?.count ?? 0
        let n2018 = catAno[2018]?.count ?? 0
        func mediana(_ p: Periodo) -> Double? { resumosPeriodo.first { $0.rotulo == p.rawValue }?.mediana }
        func diferenca(_ a: Periodo, _ b: Periodo) -> Double? {
            guard let x = mediana(a), let y = mediana(b) else { return nil }
            return x - y
        }
        let nAte2013 = basePeriodo[.ate2013]?.count ?? 0

        kpis = [
            KPI(titulo: "Lançamentos em 2013", valor: Fmt.num(n2013), icone: "calendar",
                detalhe: "Antes da abertura", detalheValor: "a indies"),
            KPI(titulo: "Lançamentos em 2018", valor: Fmt.num(n2018), icone: "calendar.badge.plus",
                detalhe: "vs. 2013",
                detalheValor: n2013 > 0 ? "×" + Fmt.dec(Double(n2018) / Double(n2013)) : "—"),
            KPI(titulo: "Mediana até 2013", valor: Fmt.pct(talvez: mediana(.ate2013)), icone: "clock.arrow.circlepath",
                detalhe: "Jogos na base", detalheValor: Fmt.num(nAte2013)),
            KPI(titulo: "Mediana 2014–2016", valor: Fmt.pct(talvez: mediana(.de2014a2016)), icone: "chart.line.downtrend.xyaxis",
                detalhe: "vs. até 2013", detalheValor: Fmt.pp(talvez: diferenca(.de2014a2016, .ate2013)),
                cor: Paleta.menor),
            KPI(titulo: "Mediana 2017–2019", valor: Fmt.pct(talvez: mediana(.de2017a2019)), icone: "chart.line.uptrend.xyaxis",
                detalhe: "vs. 2014–2016", detalheValor: Fmt.pp(talvez: diferenca(.de2017a2019, .de2014a2016))),
        ]
    }
}

struct LinhaDoTempoView: View {
    let dash: Dashboard

    var body: some View {
        let r = dash.recorte
        let m = ModeloLinhaDoTempo(r, meta: dash.meta)

//        PaginaDashboard(dash: dash, recorte: r, pagina: .linhaDoTempo, kpis: m.kpis) {
//            Painel(titulo: "Mediana da % positivas por ano de lançamento",
//                   subtitulo: "Linha = mediana; faixa = Q1 a Q3. A linha tracejada marca a abertura da loja a indies (2014).") {
//                Chart {
//                    ForEach(m.porAno) { g in
//                        AreaMark(x: .value("Ano", g.rotulo),
//                                 yStart: .value("Q1", g.q1),
//                                 yEnd: .value("Q3", g.q3))
//                            .foregroundStyle(Paleta.maior.opacity(0.15))
//                        LineMark(x: .value("Ano", g.rotulo), y: .value("Mediana", g.mediana))
//                            .foregroundStyle(Paleta.maior)
//                        PointMark(x: .value("Ano", g.rotulo), y: .value("Mediana", g.mediana))
//                            .foregroundStyle(Paleta.maior)
//                            .annotation(position: .top, spacing: 4) {
//                                Text(Fmt.dec(g.mediana, 0)).font(.caption2)
//                            }
//                    }
//                    if m.porAno.contains(where: { $0.rotulo == "2014" }) {
//                        RuleMark(x: .value("Ano", "2014"))
//                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
//                            .foregroundStyle(Color.secondary)
//                    }
//                }
//                .chartYScale(domain: m.pisoEixo...100.0)
//                .chartYAxis { marcasPercentuais(Array(stride(from: m.pisoEixo, through: 100, by: 10))) }
//                .frame(height: 250)
//            }
//
//            Painel(titulo: "Mediana e intervalo interquartil por período",
//                   subtitulo: "Os três períodos usados na comparação. Ponto = mediana; barra = Q1 a Q3.") {
//                GraficoIntervalos(grupos: m.periodos, referencia: m.medianaGeral)
//            }
//
//            Painel(titulo: "Composição da avaliação por ano",
//                   subtitulo: "Parte dos jogos lançados em cada ano que é negativa, mista ou positiva.") {
//                GraficoComposicao(fatias: m.composicao, horizontal: false)
//            }
//
//            Painel(titulo: "Como o catálogo mudou",
//                   subtitulo: "Percentual dos lançamentos de cada ano que é gratuito, multiplataforma ou indie.") {
//                Chart(m.catalogo) { item in
//                    LineMark(x: .value("Ano", item.categoria), y: .value("Percentual", item.valor))
//                        .foregroundStyle(by: .value("Indicador", item.serie))
//                        .symbol(by: .value("Indicador", item.serie))
//                }
//                .chartForegroundStyleScale(domain: ["Indie", "Multiplataforma", "Gratuitos"],
//                                           range: [Paleta.maior, Paleta.menor, Paleta.neutro])
//                .chartYScale(domain: 0.0...100.0)
//                .chartYAxis { marcasPercentuais() }
//                .chartLegend(position: .top, alignment: .leading)
//                .frame(height: 250)
//            }
//        }
    }
}
