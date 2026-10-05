// App/AppState.swift
import Foundation
import Observation

@Observable
final class AppState {
    enum Estado { case carregando, pronto(Dashboard), falha(String) }

    private(set) var estado: Estado = .carregando
    private let repo: DadosRepositoryProtocol

    init(repo: DadosRepositoryProtocol = BundleDadosRepository()) {
        self.repo = repo
    }

    func carregar() {
        do {
            estado = .pronto(Dashboard(try repo.carregar()))
        } catch {
            estado = .falha(error.localizedDescription)
        }
    }
}

/// O catálogo inteiro + os filtros da barra lateral.
/// Toda página lê `recorte`, então mudar um filtro redesenha KPIs e gráficos.
@Observable
final class Dashboard {
    let jogos: [Jogo]
    let meta: Metadados
    var filtro = FiltroGlobal()

    init(_ dados: ConjuntoDeDados) {
        jogos = dados.jogos
        meta = dados.metadados
    }

    var recorte: Recorte {
        Recorte(jogos: jogos, filtro: filtro, minAvaliacoes: meta.minAvaliacoes)
    }
}
