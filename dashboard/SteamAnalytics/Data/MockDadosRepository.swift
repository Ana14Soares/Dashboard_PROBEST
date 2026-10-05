// Data/MockDadosRepository.swift
// Três jogos reais, só para os #Preview.
import Foundation

struct MockDadosRepository: DadosRepositoryProtocol {
    func carregar() throws -> ConjuntoDeDados { .exemplo }
}

extension ConjuntoDeDados {
    static let exemplo = ConjuntoDeDados(
        jogos: [
            Jogo(appid: 730, nome: "Counter-Strike: Global Offensive", ano: 2012, preco: 0,
                 positivas: 2_644_404, negativas: 402_313, donosMin: 50_000_000, donosMax: 100_000_000,
                 plataformas: ["windows", "mac", "linux"], conquistas: 167, generos: ["Action"], indie: false),
            Jogo(appid: 578080, nome: "PLAYERUNKNOWN'S BATTLEGROUNDS", ano: 2017, preco: 26.99,
                 positivas: 496_184, negativas: 487_076, donosMin: 50_000_000, donosMax: 100_000_000,
                 plataformas: ["windows"], conquistas: 37, generos: ["Action", "Adventure"], indie: false),
            Jogo(appid: 105600, nome: "Terraria", ano: 2011, preco: 6.99,
                 positivas: 255_600, negativas: 7_797, donosMin: 5_000_000, donosMax: 10_000_000,
                 plataformas: ["windows", "mac", "linux"], conquistas: 88, generos: ["Action", "Adventure", "RPG"], indie: true),
        ],
        metadados: Metadados(geradoEm: "2026-10-04", fonte: "Exemplo", totalJogos: 3, minAvaliacoes: 50,
                             moeda: "GBP", anoMin: 2011, anoMax: 2019, anoParcial: 2019)
    )
}
