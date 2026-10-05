// Features/VisaoGeral/VisaoGeralView.swift
import SwiftUI
import Charts

/// Tudo o que a página mostra, calculado do recorte filtrado.
struct ModeloVisaoGeral {
    struct Bin: Identifiable {
        let inicio: Int
        let qtd: Int
        var id: Int { inicio }
    }

    let kpis: [KPI]
    let lancamentos: [ItemGrafico]   // jogos lançados por ano, desde 2006
    let histograma: [Bin]            // % positivas em faixas de 5 pontos
    let mediana: Double?
    let perfil: [ItemGrafico]        // % da base em cada faixa de avaliação
    let alcance: [ItemGrafico]       // nº de jogos por faixa de donos
    let totalCatalogo: Int

    init(_ r: Recorte, meta: Metadados) {
        let cat = r.catalogo, base = r.base
        let pcts = base.map(\.pctPositivas)
        let med = Estat.mediana(pcts)
        mediana = med
        totalCatalogo = cat.count

        // Concentração: fatia dos donos (ponto médio da faixa) que fica com o 1% de jogos maiores.
        let donos = cat.map(\.donosMedio).sorted(by: >)
        let topo = Int((Double(donos.count) * 0.01).rounded(.up))
        let somaDonos = donos.reduce(0, +)
        let concentracao: Double? = somaDonos > 0 ? donos.prefix(topo).reduce(0, +) / somaDonos * 100 : nil

        kpis = [
            KPI(titulo: "Jogos no catálogo", valor: Fmt.num(cat.count), icone: "square.stack.3d.up.fill",
                detalhe: "Indie", detalheValor: Fmt.pct(talvez: Estat.pct(cat) { $0.indie })),
            KPI(titulo: "Base de avaliação", valor: Fmt.num(base.count), icone: "text.bubble.fill",
                detalhe: "do catálogo",
                detalheValor: Fmt.pct(talvez: cat.isEmpty ? nil : Double(base.count) / Double(cat.count) * 100)),
            KPI(titulo: "% positivas (mediana)", valor: Fmt.pct(talvez: med), icone: "hand.thumbsup.fill",
                detalhe: "Bem avaliados (≥ 80%)",
                detalheValor: Fmt.pct(talvez: Estat.pct(base) { $0.pctPositivas >= 80 }),
                cor: Paleta.cor(.positiva)),
            KPI(titulo: "Preço mediano (pagos)",
                valor: Fmt.libra(talvez: Estat.mediana(cat.filter { !$0.gratuito }.map(\.preco))),
                icone: "sterlingsign.circle.fill",
                detalhe: "Gratuitos", detalheValor: Fmt.pct(talvez: Estat.pct(cat) { $0.gratuito })),
            KPI(titulo: "Donos no 1% maior", valor: Fmt.pct(talvez: concentracao), icone: "person.3.fill",
                detalhe: "Até 20 mil donos",
                detalheValor: Fmt.pct(talvez: Estat.pct(cat) { !$0.acimaVinteMil })),
        ]

        let porAno = Dictionary(grouping: cat, by: \.ano).mapValues(\.count)
        lancamentos = (2006...meta.anoMax).map { ano in
            ItemGrafico(rotulo: String(ano), valor: Double(porAno[ano] ?? 0),
                        cor: ano == meta.anoParcial ? Paleta.neutro.opacity(0.5) : Paleta.maior)
        }

        var contagem = Array(repeating: 0, count: 20)
        for p in pcts { contagem[min(Int(p / 5), 19)] += 1 }   // 100% entra na última faixa
        histograma = contagem.enumerated().map { Bin(inicio: $0.offset * 5, qtd: $0.element) }

        perfil = FaixaAvaliacao.allCases.map { faixa in
            ItemGrafico(rotulo: faixa.rawValue,
                        valor: Estat.pct(base, onde: { $0.faixaAvaliacao == faixa }) ?? 0,
                        cor: Paleta.cor(faixa))
        }

        alcance = Alcance.allCases.map { a in
            ItemGrafico(rotulo: a.rawValue, valor: Double(cat.filter { $0.alcance == a }.count),
                        cor: a == .ate20mil ? Paleta.menor : Paleta.maior)
        }
    }
}

struct VisaoGeralView: View {
    let dash: Dashboard

    var body: some View {
        let r = dash.recorte
        let m = ModeloVisaoGeral(r, meta: dash.meta)

        PaginaDashboard(dash: dash, recorte: r, pagina: .visaoGeral, kpis: m.kpis) {
            Painel(titulo: "Lançamentos por ano",
                   subtitulo: "Jogos do catálogo por ano de lançamento. Em 2014 a loja se abriu a estúdios independentes; \(String(dash.meta.anoParcial)) está incompleto (cinza).") {
                GraficoBarras(itens: m.lancamentos, formato: { Fmt.num(Int($0)) }, altura: 240)
            }

            Painel(titulo: "Distribuição da % de avaliações positivas",
                   subtitulo: "Jogos com ≥ \(r.minAvaliacoes) avaliações, em faixas de 5 pontos. A cauda à esquerda é o motivo dos testes não paramétricos.") {
                Chart {
                    ForEach(m.histograma) { b in
                        BarMark(xStart: .value("De", Double(b.inicio)),
                                xEnd: .value("Até", Double(b.inicio + 5)),
                                y: .value("Jogos", b.qtd))
                            .foregroundStyle(Paleta.cor(FaixaAvaliacao(pct: Double(b.inicio))))
                    }
                    if let mediana = m.mediana {
                        RuleMark(x: .value("Mediana", mediana))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                            .foregroundStyle(Color.primary)
                            .annotation(position: .top, alignment: .leading, spacing: 2) {
                                Text("mediana \(Fmt.pct(mediana))").font(.caption2.bold())
                            }
                    }
                }
                .chartXScale(domain: 0.0...100.0)
                .chartXAxis { marcasPercentuais([0, 20, 40, 60, 80, 100]) }
                .frame(height: 240)
            }

            Painel(titulo: "Perfil de avaliação",
                   subtitulo: "Parte da base em cada faixa. \"Positiva\" (≥ 80%) é o que o trabalho chama de bem avaliado.") {
                GraficoRosca(fatias: m.perfil)
            }

            Painel(titulo: "Jogos por faixa de donos",
                   subtitulo: "Faixas estimadas pelo SteamSpy. A maioria dos jogos nunca passa de 20 mil donos.") {
                GraficoBarras(itens: m.alcance, horizontal: true, formato: { v in
                    let total = Double(max(m.totalCatalogo, 1))
                    return "\(Fmt.num(Int(v))) · \(Fmt.pct(v / total * 100))"
                })
            }
        }
    }
}

#Preview {
    VisaoGeralView(dash: Dashboard(.exemplo))
        .frame(width: 1200, height: 900)
}
