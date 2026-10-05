// Components/TabelaContingencia.swift
import SwiftUI

/// Tabela 2 × 2 com contagens e percentual por linha.
struct TabelaContingencia: View {
    let linhas: [String]
    let colunas: [String]
    let valores: [[Int]]

    private func pctLinha(_ i: Int, _ j: Int) -> Double {
        let total = valores[i].reduce(0, +)
        return total > 0 ? Double(valores[i][j]) / Double(total) * 100 : 0
    }

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 10) {
            GridRow {
                Text("")
                ForEach(colunas, id: \.self) { Text($0).font(.caption.bold()) }
                Text("Total").font(.caption.bold())
            }
            Divider()
            ForEach(linhas.indices, id: \.self) { i in
                GridRow {
                    Text(linhas[i])
                        .font(.callout.bold())
                        .gridColumnAlignment(.leading)
                    ForEach(valores[i].indices, id: \.self) { j in
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(Fmt.num(valores[i][j])).font(.title3.monospacedDigit())
                            Text(Fmt.pct(pctLinha(i, j)))
                                .font(.caption)
                                .foregroundStyle(j == valores[i].count - 1 ? Paleta.cor(.positiva) : .secondary)
                        }
                    }
                    Text(Fmt.num(valores[i].reduce(0, +))).monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
