// Models/FiltroGlobal.swift
import Foundation

/// Os filtros da barra lateral. Valem para todas as páginas ao mesmo tempo,
/// como os segmentadores sincronizados de um painel do Power BI.
struct FiltroGlobal: Equatable, Sendable {
    var periodo: Periodo? = nil
    var genero: String? = nil
    var preco: OpcaoPreco = .todos
    var plataforma: OpcaoPlataforma = .todas
    var conquistas: OpcaoConquistas = .todos

    enum OpcaoPreco: String, CaseIterable, Identifiable, Sendable {
        case todos = "Todos", gratuitos = "Gratuitos", pagos = "Pagos"
        var id: String { rawValue }
    }

    enum OpcaoPlataforma: String, CaseIterable, Identifiable, Sendable {
        case todas = "Todas", uma = "Uma plataforma", multi = "Multiplataforma"
        var id: String { rawValue }
    }

    enum OpcaoConquistas: String, CaseIterable, Identifiable, Sendable {
        case todos = "Todos", com = "Com conquistas", sem = "Sem conquistas"
        var id: String { rawValue }
    }

    var ativo: Bool { self != FiltroGlobal() }

    func aceita(_ j: Jogo) -> Bool {
        if let periodo, j.periodo != periodo { return false }
        if let genero, !j.generos.contains(genero) { return false }
        if preco == .gratuitos && !j.gratuito { return false }
        if preco == .pagos && j.gratuito { return false }
        if plataforma == .uma && j.multiplataforma { return false }
        if plataforma == .multi && !j.multiplataforma { return false }
        if conquistas == .com && !j.temConquistas { return false }
        if conquistas == .sem && j.temConquistas { return false }
        return true
    }

    /// Texto curto para o cabeçalho: "2014–2016 · Action · Pagos".
    var descricao: String {
        var partes: [String] = []
        if let periodo { partes.append(periodo.rawValue) }
        if let genero { partes.append(genero) }
        if preco != .todos { partes.append(preco.rawValue) }
        if plataforma != .todas { partes.append(plataforma.rawValue) }
        if conquistas != .todos { partes.append(conquistas.rawValue) }
        return partes.isEmpty ? "Sem filtros" : partes.joined(separator: " · ")
    }
}

/// O catálogo depois dos filtros, separado nas duas bases do trabalho.
struct Recorte {
    /// Todos os jogos que passam no filtro: contagens, preço, donos, plataformas.
    let catalogo: [Jogo]
    /// Os que têm pelo menos `minAvaliacoes`: tudo que usa % de avaliações positivas.
    let base: [Jogo]
    let minAvaliacoes: Int

    init(jogos: [Jogo], filtro: FiltroGlobal, minAvaliacoes: Int) {
        catalogo = jogos.filter { filtro.aceita($0) }
        base = catalogo.filter { $0.totalAvaliacoes >= minAvaliacoes }
        self.minAvaliacoes = minAvaliacoes
    }
}
