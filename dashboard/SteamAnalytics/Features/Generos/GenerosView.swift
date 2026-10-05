// Features/Generos/GenerosView.swift
// Dados para falar de H4 (avaliação por gênero). Usa o "gênero único" do notebook:
// jogos com exatamente um dos 8 gêneros principais, para os grupos não se misturarem.
import SwiftUI
import Charts

struct ModeloGeneros {
    let kpis: [KPI]
    let ranking: [ItemGrafico]          // mediana por gênero, do maior para o menor
    let intervalos: [ResumoGrupo]
    let medianaGeral: Double?
    let avaliacaoAlcance: [ItemSerie]   // % bem avaliados × % acima de 20 mil donos
    let composicao: [FatiaComposicao]

    init(_ r: Recorte) {
        let geral = Estat.mediana(r.base.map(\.pctPositivas))
        medianaGeral = geral

        let baseGenero = Dictionary(grouping: r.base.filter { $0.generoUnico != nil }) { $0.generoUnico ?? "" }
        let catGenero = Dictionary(grouping: r.catalogo.filter { $0.generoUnico != nil }) { $0.generoUnico ?? "" }

        let resumos = baseGenero
            .compactMap { Estat.resumo($0.key, $0.value.map(\.pctPositivas)) }
            .sorted { $0.mediana > $1.mediana }
        intervalos = resumos

        ranking = resumos.map { g in
            ItemGrafico(rotulo: g.rotulo, valor: g.mediana,
                        cor: g.mediana >= (geral ?? 0) ? Paleta.maior : Paleta.menor)
        }

        var serie: [ItemSerie] = []
        var alcancePorGenero: [(String, Double)] = []
        for g in resumos.map(\.rotulo) {
            if let v = Estat.pct(baseGenero[g] ?? [], onde: { $0.pctPositivas >= 80 }) {
                serie.append(ItemSerie(categoria: g, serie: "Bem avaliados (≥ 80%)", valor: v))
            }
            if let v = Estat.pct(catGenero[g] ?? [], onde: { $0.acimaVinteMil }) {
                serie.append(ItemSerie(categoria: g, serie: "Mais de 20 mil donos", valor: v))
                alcancePorGenero.append((g, v))
            }
        }
        avaliacaoAlcance = serie
        let maiorAlcance = alcancePorGenero.max { $0.1 < $1.1 }

        composicao = FatiaComposicao.de(resumos.map { ($0.rotulo, baseGenero[$0.rotulo] ?? []) })

        let primeiro = resumos.first, ultimo = resumos.last
        var amplitude: Double? = nil
        if let p = primeiro, let u = ultimo, resumos.count > 1 { amplitude = p.mediana - u.mediana }
        let nGenero = baseGenero.values.reduce(0) { $0 + $1.count }

        kpis = [
            KPI(titulo: "Mais bem avaliado", valor: primeiro?.rotulo ?? "—", icone: "arrow.up.circle.fill",
                detalhe: "Mediana", detalheValor: Fmt.pct(talvez: primeiro?.mediana), cor: Paleta.maior),
            KPI(titulo: "Pior avaliado", valor: ultimo?.rotulo ?? "—", icone: "arrow.down.circle.fill",
                detalhe: "Mediana", detalheValor: Fmt.pct(talvez: ultimo?.mediana), cor: Paleta.menor),
            KPI(titulo: "Distância 1º − último", valor: amplitude.map { Fmt.dec($0) + " p.p." } ?? "—",
                icone: "arrow.left.and.right.circle.fill",
                detalhe: "Gêneros comparados", detalheValor: Fmt.num(resumos.count)),
            KPI(titulo: "Maior alcance", valor: maiorAlcance?.0 ?? "—", icone: "person.3.fill",
                detalhe: "> 20 mil donos", detalheValor: Fmt.pct(talvez: maiorAlcance?.1)),
            KPI(titulo: "Jogos de gênero único", valor: Fmt.num(nGenero), icone: "tag.fill",
                detalhe: "da base",
                detalheValor: Fmt.pct(talvez: r.base.isEmpty ? nil : Double(nGenero) / Double(r.base.count) * 100)),
        ]
    }
}

struct GenerosView: View {
    let dash: Dashboard

    var body: some View {
        let r = dash.recorte
        let m = ModeloGeneros(r)

//        PaginaDashboard(dash: dash, recorte: r, pagina: .generos, kpis: m.kpis) {
//            Painel(titulo: "Ranking: mediana da % positivas por gênero",
//                   subtitulo: "Azul = acima da mediana geral (\(Fmt.pct(talvez: m.medianaGeral))); laranja = abaixo.") {
//                GraficoBarras(itens: m.ranking, horizontal: true, formato: { Fmt.pct($0) }, percentual: true)
//            }

            Painel(titulo: "Mediana e intervalo interquartil por gênero",
                   subtitulo: "Os gêneros diferem na mediana, mas as faixas Q1–Q3 se sobrepõem bastante.") {
                GraficoIntervalos(grupos: m.intervalos, referencia: m.medianaGeral)
            }

            Painel(titulo: "Avaliação × alcance por gênero",
                   subtitulo: "O gênero mais bem avaliado nem sempre é o que tem mais público.") {
                GraficoAgrupado(itens: m.avaliacaoAlcance,
                                series: ["Bem avaliados (≥ 80%)", "Mais de 20 mil donos"],
                                cores: [Paleta.maior, Paleta.menor],
                                horizontal: true)
            }

            Painel(titulo: "Composição da avaliação por gênero",
                   subtitulo: "Parte dos jogos de cada gênero que é negativa, mista ou positiva.") {
                GraficoComposicao(fatias: m.composicao)
            }
        }
    }

