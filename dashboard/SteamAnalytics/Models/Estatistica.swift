// Models/Estatistica.swift
import Foundation

/// Estatística descritiva usada pelas páginas. Testes de hipótese ficam no notebook.
enum Estat {
    /// Quantil com interpolação linear: o mesmo método do `Series.quantile` do pandas,
    /// para os números do app baterem com os do notebook.
    static func quantil(_ ordenados: [Double], _ p: Double) -> Double? {
        guard !ordenados.isEmpty else { return nil }
        let h = Double(ordenados.count - 1) * p
        let i = Int(h.rounded(.down))
        let j = min(i + 1, ordenados.count - 1)
        return ordenados[i] + (h - Double(i)) * (ordenados[j] - ordenados[i])
    }

    static func mediana(_ valores: [Double]) -> Double? {
        quantil(valores.sorted(), 0.5)
    }

    /// Percentual dos itens que atendem à condição (nil quando não há itens).
    static func pct<T>(_ itens: [T], onde condicao: (T) -> Bool) -> Double? {
        guard !itens.isEmpty else { return nil }
        return Double(itens.filter(condicao).count) / Double(itens.count) * 100
    }

    /// Mediana e intervalo interquartil de um grupo.
    static func resumo(_ rotulo: String, _ valores: [Double]) -> ResumoGrupo? {
        let s = valores.sorted()
        guard let q1 = quantil(s, 0.25), let md = quantil(s, 0.5), let q3 = quantil(s, 0.75) else {
            return nil
        }
        return ResumoGrupo(rotulo: rotulo, n: s.count, q1: q1, mediana: md, q3: q3)
    }
}

struct ResumoGrupo: Identifiable {
    let rotulo: String
    let n: Int
    let q1: Double
    let mediana: Double
    let q3: Double
    var id: String { rotulo }
}
