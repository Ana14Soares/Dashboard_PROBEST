// Features/Preco/PrecoView.swift
// Dados para falar de H1 (gratuito × pago) e H3 (preço × avaliação).
import SwiftUI
import Charts

struct ModeloPreco {
    struct Ponto: Identifiable {
        let id: Int
        let preco: Double
        let pct: Double
        let faixa: FaixaAvaliacao
    }

    let kpis: [KPI]
    let gratisPago: [ResumoGrupo]        // mediana + Q1–Q3 de cada grupo
    let medianaGeral: Double?
    let porFaixa: [ItemGrafico]          // mediana da % positivas por faixa de preço
    let composicao: [FatiaComposicao]    // faixas de avaliação dentro de cada faixa de preço
    let dispersao: [Ponto]               // amostra de jogos pagos

    init(_ r: Recorte) {
        let base = r.base
        let gratis = base.filter(\.gratuito).map(\.pctPositivas)
        let pagos = base.filter { !$0.gratuito }.map(\.pctPositivas)
        let rg = Estat.resumo("Gratuito", gratis)
        let rp = Estat.resumo("Pago", pagos)
        gratisPago = [rg, rp].compactMap { $0 }
        medianaGeral = Estat.mediana(base.map(\.pctPositivas))

        var diferenca: Double? = nil
        if let g = rg?.mediana, let p = rp?.mediana { diferenca = g - p }

        let grupos = Dictionary(grouping: base, by: \.faixaPreco)
        let itens = FaixaPreco.allCases.compactMap { f -> ItemGrafico? in
            guard let m = Estat.mediana((grupos[f] ?? []).map(\.pctPositivas)) else { return nil }
            return ItemGrafico(rotulo: f.rawValue, valor: m)
        }
        let destacados = ItemGrafico.destacandoExtremos(itens)
        porFaixa = destacados
        let melhor = destacados.max { $0.valor < $1.valor }

        composicao = FatiaComposicao.de(FaixaPreco.allCases.map { ($0.rawValue, grupos[$0] ?? []) })

        // Até 1.500 pontos, espalhados por todo o ranking de popularidade.
        let jogosPagos = base.filter { !$0.gratuito }
        let passo = max(1, jogosPagos.count / 1500)
        dispersao = stride(from: 0, to: jogosPagos.count, by: passo).map { i in
            let j = jogosPagos[i]
            return Ponto(id: j.appid, preco: j.preco, pct: j.pctPositivas, faixa: j.faixaAvaliacao)
        }

        let precosPagos = r.catalogo.filter { !$0.gratuito }.map(\.preco)
        kpis = [
            KPI(titulo: "Mediana — gratuitos", valor: Fmt.pct(talvez: rg?.mediana), icone: "gift.fill",
                detalhe: "Jogos na base", detalheValor: Fmt.num(gratis.count)),
            KPI(titulo: "Mediana — pagos", valor: Fmt.pct(talvez: rp?.mediana), icone: "cart.fill",
                detalhe: "Jogos na base", detalheValor: Fmt.num(pagos.count)),
            KPI(titulo: "Preço mediano (pagos)", valor: Fmt.libra(talvez: Estat.mediana(precosPagos)),
                icone: "sterlingsign.circle.fill",
                detalhe: "Mais caro", detalheValor: Fmt.libra(talvez: precosPagos.max())),
            KPI(titulo: "Faixa mais bem avaliada", valor: melhor?.rotulo ?? "—", icone: "trophy.fill",
                detalhe: "Mediana", detalheValor: Fmt.pct(talvez: melhor?.valor)),
        ]
    }
}

struct PrecoView: View {
    let dash: Dashboard

    var body: some View {
        let r = dash.recorte
        let m = ModeloPreco(r)

        PaginaDashboard(dash: dash, recorte: r, pagina: .preco, kpis: m.kpis) {
            Painel(titulo: "Gratuitos × pagos: mediana e intervalo interquartil",
                   subtitulo: "Ponto = mediana da % positivas; barra = Q1 a Q3. Quanto mais as barras se sobrepõem, menor a diferença na prática.") {
                GraficoIntervalos(grupos: m.gratisPago, referencia: m.medianaGeral)
            }

            Painel(titulo: "Mediana da % positivas por faixa de preço",
                   subtitulo: "Azul = faixa mais bem avaliada; laranja = a pior. Cortes iguais aos do notebook.") {
                GraficoBarras(itens: m.porFaixa, formato: { Fmt.pct($0) }, percentual: true)
            }

            Painel(titulo: "Composição da avaliação por faixa de preço",
                   subtitulo: "Parte dos jogos de cada faixa que é negativa, mista ou positiva.") {
                GraficoComposicao(fatias: m.composicao)
            }

//            Painel(titulo: "Preço × % positivas (jogos pagos)",
//                   subtitulo: "Amostra de \(Fmt.num(m.dispersao.count)) jogos. Eixo de preço em escala logarítmica.") {
//                Chart(m.dispersao) { p in
//                    PointMark(x: .value("Preço (£)", p.preco), y: .value("% positivas", p.pct))
//                        .symbolSize(14)
//                        .opacity(0.6)
//                        .foregroundStyle(by: .value("Avaliação", p.faixa.rawValue))
//                }
//                .chartXScale(domain: 0.5...500.0, type: .log)
//                .chartXAxis {
//                    AxisMarks(values: [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0]) { valor in
//                        AxisGridLine()
//                        AxisValueLabel {
//                            if let v = valor.as(Double.self) { Text("£\(Int(v))") }
//                        }
//                    }
//                }
//                .chartYScale(domain: 0.0...100.0)
//                .chartYAxis { marcasPercentuais() }
//                .chartForegroundStyleScale(domain: FaixaAvaliacao.allCases.map(\.rawValue),
//                                           range: FaixaAvaliacao.allCases.map { Paleta.cor($0) })
//                .chartLegend(position: .top, alignment: .leading)
//                .frame(height: 260)
//            }
        }
    }
}
