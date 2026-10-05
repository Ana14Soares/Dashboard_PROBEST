// Components/Graficos.swift
// Gráficos reutilizados pelas páginas. Regra de cor: azul = maior valor,
// laranja = menor, cinza = intermediários; faixas de avaliação têm cor própria.
import SwiftUI
import Charts

// MARK: - Dados dos gráficos

struct ItemGrafico: Identifiable {
    let rotulo: String
    let valor: Double
    var cor: Color = Paleta.maior
    var id: String { rotulo }

    /// Pinta de azul o maior valor, de laranja o menor e de cinza o resto.
    static func destacandoExtremos(_ itens: [ItemGrafico]) -> [ItemGrafico] {
        let maior = itens.map(\.valor).max()
        let menor = itens.map(\.valor).min()
        return itens.map { item in
            var novo = item
            novo.cor = item.valor == maior ? Paleta.maior
                     : item.valor == menor ? Paleta.menor
                     : Paleta.neutro
            return novo
        }
    }
}

/// Um valor de uma série numa categoria (barras agrupadas e linhas).
struct ItemSerie: Identifiable {
    let categoria: String
    let serie: String
    let valor: Double
    var id: String { "\(categoria)|\(serie)" }
}

/// Parte de uma barra 100%: quanto de um grupo cai numa faixa de avaliação.
struct FatiaComposicao: Identifiable {
    let grupo: String
    let faixa: FaixaAvaliacao
    let pct: Double
    var id: String { "\(grupo)|\(faixa.rawValue)" }

    /// Uma barra por grupo, dividida em negativa / mista / positiva. Grupos vazios saem.
    static func de(_ grupos: [(String, [Jogo])]) -> [FatiaComposicao] {
        grupos.filter { !$0.1.isEmpty }.flatMap { grupo in
            FaixaAvaliacao.allCases.map { faixa in
                FatiaComposicao(grupo: grupo.0, faixa: faixa,
                                pct: Estat.pct(grupo.1, onde: { $0.faixaAvaliacao == faixa }) ?? 0)
            }
        }
    }
}

/// Marcas de eixo "0%, 25%, …" para eixos de percentual.
func marcasPercentuais(_ valores: [Double] = [0, 25, 50, 75, 100]) -> some AxisContent {
    AxisMarks(values: valores) { valor in
        AxisGridLine()
        AxisValueLabel {
            if let v = valor.as(Double.self) { Text("\(Int(v))%") }
        }
    }
}

// MARK: - Barras simples

/// Barras com o valor escrito em cada uma (verticais ou horizontais).
struct GraficoBarras: View {
    let itens: [ItemGrafico]
    var horizontal = false
    var formato: (Double) -> String = { Fmt.num(Int($0)) }
    var altura: CGFloat? = nil
    /// true: eixo de valores fixo em 0–100%.
    var percentual = false

    var body: some View {
        Chart(itens) { item in
            if horizontal {
                BarMark(x: .value("Valor", item.valor), y: .value("Grupo", item.rotulo))
                    .foregroundStyle(item.cor)
                    .cornerRadius(4)
                    .annotation(position: .trailing, spacing: 4) {
                        Text(formato(item.valor)).font(.caption2.bold())
                    }
            } else {
                BarMark(x: .value("Grupo", item.rotulo), y: .value("Valor", item.valor))
                    .foregroundStyle(item.cor)
                    .cornerRadius(4)
                    .annotation(position: .top, spacing: 2) {
                        Text(formato(item.valor)).font(.caption2.bold())
                    }
            }
        }
        .modifier(EixoPercentual(horizontal: horizontal, ativo: percentual, limite: horizontal ? 115 : 110))
        .frame(height: altura ?? (horizontal ? CGFloat(itens.count) * 34 + 30 : 230))
    }
}

// MARK: - Barras agrupadas

/// Duas ou mais séries lado a lado em cada categoria.
struct GraficoAgrupado: View {
    let itens: [ItemSerie]
    let series: [String]
    let cores: [Color]
    var horizontal = false
    var formato: (Double) -> String = { Fmt.pct($0) }

    private var categorias: Int { Set(itens.map(\.categoria)).count }

    var body: some View {
        Chart(itens) { item in
            if horizontal {
                BarMark(x: .value("Valor", item.valor), y: .value("Categoria", item.categoria))
                    .position(by: .value("Série", item.serie))
                    .foregroundStyle(by: .value("Série", item.serie))
                    .annotation(position: .trailing, spacing: 2) {
                        Text(formato(item.valor)).font(.caption2)
                    }
            } else {
                BarMark(x: .value("Categoria", item.categoria), y: .value("Valor", item.valor))
                    .position(by: .value("Série", item.serie))
                    .foregroundStyle(by: .value("Série", item.serie))
                    .annotation(position: .top, spacing: 2) {
                        Text(formato(item.valor)).font(.caption2)
                    }
            }
        }
        .chartForegroundStyleScale(domain: series, range: cores)
        .chartLegend(position: .top, alignment: .leading)
        .frame(height: horizontal ? CGFloat(categorias) * 46 + 50 : 250)
    }
}

// MARK: - Composição 100%

/// Barras 100% divididas por faixa de avaliação.
struct GraficoComposicao: View {
    let fatias: [FatiaComposicao]
    var horizontal = true

    private var grupos: Int { Set(fatias.map(\.grupo)).count }

    var body: some View {
        Chart(fatias) { f in
            if horizontal {
                BarMark(x: .value("Percentual", f.pct), y: .value("Grupo", f.grupo))
                    .foregroundStyle(by: .value("Avaliação", f.faixa.rawValue))
                    .annotation(position: .overlay) { rotulo(f) }
            } else {
                BarMark(x: .value("Grupo", f.grupo), y: .value("Percentual", f.pct))
                    .foregroundStyle(by: .value("Avaliação", f.faixa.rawValue))
                    .annotation(position: .overlay) { rotulo(f) }
            }
        }
        .chartForegroundStyleScale(domain: FaixaAvaliacao.allCases.map(\.rawValue),
                                   range: FaixaAvaliacao.allCases.map { Paleta.cor($0) })
        .chartLegend(position: .top, alignment: .leading)
        .modifier(EixoPercentual(horizontal: horizontal, ativo: true))
        .frame(height: horizontal ? CGFloat(grupos) * 34 + 50 : 260)
    }

    @ViewBuilder
    private func rotulo(_ f: FatiaComposicao) -> some View {
        if f.pct >= 9 {
            Text(Fmt.pct(f.pct, 0))
                .font(.caption2.bold())
                .foregroundStyle(f.faixa == .mista ? Color.black.opacity(0.7) : .white)
        }
    }
}

/// Fixa o eixo de valores em 0–100% (ou um pouco mais, para caber o rótulo da barra).
/// Sem percentual, só reserva espaço à direita para o rótulo das barras horizontais.
private struct EixoPercentual: ViewModifier {
    let horizontal: Bool
    let ativo: Bool
    var limite = 100.0

    func body(content: Content) -> some View {
        if !ativo && horizontal {
            content.chartXScale(range: .plotDimension(endPadding: 56))
        } else if !ativo {
            content
        } else if horizontal {
            content
                .chartXScale(domain: 0.0...limite)
                .chartXAxis { marcasPercentuais() }
        } else {
            content
                .chartYScale(domain: 0.0...limite)
                .chartYAxis { marcasPercentuais() }
        }
    }
}

// MARK: - Mediana e intervalo interquartil

/// Ponto = mediana; barra clara = Q1 a Q3. Mostra a diferença entre grupos
/// e, ao mesmo tempo, o quanto eles se sobrepõem.
struct GraficoIntervalos: View {
    let grupos: [ResumoGrupo]
    var referencia: Double? = nil

    private var inicioEixo: Double {
        let menor = grupos.map(\.q1).min() ?? 40
        return max(0, (menor / 10).rounded(.down) * 10)
    }

    private func cor(_ g: ResumoGrupo) -> Color {
        let medianas = grupos.map(\.mediana)
        if grupos.count > 1, g.mediana == medianas.max() { return Paleta.maior }
        if grupos.count > 1, g.mediana == medianas.min() { return Paleta.menor }
        return Paleta.neutro
    }

    var body: some View {
        Chart {
            if let referencia {
                RuleMark(x: .value("Mediana geral", referencia))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(Color.secondary)
                    .annotation(position: .top, spacing: 2) {
                        Text("mediana geral \(Fmt.pct(referencia))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            }
            ForEach(grupos) { g in
                BarMark(xStart: .value("Q1", g.q1), xEnd: .value("Q3", g.q3),
                        y: .value("Grupo", g.rotulo), height: .fixed(12))
                    .cornerRadius(6)
                    .foregroundStyle(cor(g).opacity(0.25))
                PointMark(x: .value("Mediana", g.mediana), y: .value("Grupo", g.rotulo))
                    .symbolSize(110)
                    .foregroundStyle(cor(g))
                    .annotation(position: .top, spacing: 1) {
                        Text(Fmt.pct(g.mediana))
                            .font(.caption2.bold())
                            .foregroundStyle(cor(g))
                    }
            }
        }
        .chartXScale(domain: inicioEixo...100.0)
        .chartXAxis { marcasPercentuais(Array(stride(from: inicioEixo, through: 100, by: 10))) }
        .frame(height: CGFloat(grupos.count) * 44 + 44)
    }
}

// MARK: - Rosca

/// Partes de um todo (valores em %).
struct GraficoRosca: View {
    let fatias: [ItemGrafico]

    var body: some View {
        Chart(fatias) { f in
            SectorMark(angle: .value("Percentual", f.valor), innerRadius: .ratio(0.58), angularInset: 1.5)
                .cornerRadius(3)
                .foregroundStyle(by: .value("Faixa", f.rotulo))
                .annotation(position: .overlay) {
                    if f.valor >= 6 {
                        Text(Fmt.pct(f.valor))
                            .font(.caption.bold())
                            .foregroundStyle(Paleta.textoSobre(f.cor))
                    }
                }
        }
        .chartForegroundStyleScale(domain: fatias.map(\.rotulo), range: fatias.map(\.cor))
        .chartLegend(position: .trailing, alignment: .center)
        .frame(height: 230)
    }
}
