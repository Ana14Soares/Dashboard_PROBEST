// Models/Jogo.swift
import Foundation

/// Um jogo do catálogo (27.075 no total). Só os campos brutos vêm do JSON;
/// tudo o que é derivado (% positivas, faixas, período) é calculado aqui,
/// com as mesmas regras do notebook.
struct Jogo: Codable, Sendable, Identifiable {
    let appid: Int
    let nome: String
    let ano: Int
    let preco: Double            // GBP
    let positivas: Int
    let negativas: Int
    let donosMin: Int            // faixa estimada do SteamSpy
    let donosMax: Int
    let plataformas: [String]    // "windows", "mac", "linux"
    let conquistas: Int
    let generos: [String]        // só os 8 gêneros principais
    let indie: Bool

    var id: Int { appid }
    var totalAvaliacoes: Int { positivas + negativas }
    var pctPositivas: Double {
        totalAvaliacoes > 0 ? Double(positivas) / Double(totalAvaliacoes) * 100 : 0
    }
    var gratuito: Bool { preco == 0 }
    var multiplataforma: Bool { plataformas.count > 1 }
    var temConquistas: Bool { conquistas > 0 }
    /// Gênero quando o jogo tem exatamente um dos 8 principais (recorte da H4).
    var generoUnico: String? { generos.count == 1 ? generos[0] : nil }
    var donosMedio: Double { Double(donosMin + donosMax) / 2 }
    var acimaVinteMil: Bool { donosMin >= 20_000 }

    var faixaAvaliacao: FaixaAvaliacao { FaixaAvaliacao(pct: pctPositivas) }
    var faixaPreco: FaixaPreco { FaixaPreco(preco: preco) }
    var periodo: Periodo { Periodo(ano: ano) }
    var alcance: Alcance { Alcance(donosMin: donosMin) }
}

/// Os 8 gêneros principais usados no notebook.
let generosPrincipais = ["Action", "Adventure", "Casual", "RPG",
                         "Simulation", "Strategy", "Sports", "Racing"]

/// Faixas de avaliação. "Positiva" (≥ 80%) é o critério de "bem avaliado" da H2.
enum FaixaAvaliacao: String, CaseIterable, Identifiable, Sendable {
    case negativa = "Negativa (< 50%)"
    case mista    = "Mista (50–80%)"
    case positiva = "Positiva (≥ 80%)"

    var id: String { rawValue }

    init(pct: Double) {
        if pct >= 80 { self = .positiva }
        else if pct >= 50 { self = .mista }
        else { self = .negativa }
    }
}

/// Mesmos cortes do notebook: (0, 5], (5, 10], (10, 20], acima de 20.
enum FaixaPreco: String, CaseIterable, Identifiable, Sendable {
    case gratuito = "Gratuito"
    case ate5     = "até £5"
    case de5a10   = "£5–10"
    case de10a20  = "£10–20"
    case acima20  = "acima de £20"

    var id: String { rawValue }

    init(preco: Double) {
        if preco == 0 { self = .gratuito }
        else if preco <= 5 { self = .ate5 }
        else if preco <= 10 { self = .de5a10 }
        else if preco <= 20 { self = .de10a20 }
        else { self = .acima20 }
    }
}

/// Períodos de lançamento usados na H6.
enum Periodo: String, CaseIterable, Identifiable, Sendable {
    case ate2013     = "até 2013"
    case de2014a2016 = "2014–2016"
    case de2017a2019 = "2017–2019"

    var id: String { rawValue }

    init(ano: Int) {
        if ano <= 2013 { self = .ate2013 }
        else if ano <= 2016 { self = .de2014a2016 }
        else { self = .de2017a2019 }
    }
}

/// Faixas de donos agrupadas (as 13 faixas do SteamSpy viram 5).
enum Alcance: String, CaseIterable, Identifiable, Sendable {
    case ate20mil  = "até 20 mil"
    case ate100mil = "20–100 mil"
    case ate1mi    = "100 mil–1 mi"
    case ate10mi   = "1–10 mi"
    case acima10mi = "acima de 10 mi"

    var id: String { rawValue }

    init(donosMin: Int) {
        switch donosMin {
        case ..<20_000:     self = .ate20mil
        case ..<100_000:    self = .ate100mil
        case ..<1_000_000:  self = .ate1mi
        case ..<10_000_000: self = .ate10mi
        default:            self = .acima10mi
        }
    }
}
