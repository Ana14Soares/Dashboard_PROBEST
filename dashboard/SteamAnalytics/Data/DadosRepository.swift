// Data/DadosRepository.swift
import Foundation

protocol DadosRepositoryProtocol: Sendable {
    func carregar() throws -> ConjuntoDeDados
}

struct ConjuntoDeDados: Sendable {
    let jogos: [Jogo]
    let metadados: Metadados
}

enum ErroDados: LocalizedError {
    case arquivoNaoEncontrado(String)
    case falhaDecodificacao(String, Error)

    var errorDescription: String? {
        switch self {
        case .arquivoNaoEncontrado(let nome):
            "Arquivo \(nome).json não está no bundle do app."
        case .falhaDecodificacao(let nome, let erro):
            // String(describing:) mostra qual chave faltou, e não só "data is missing".
            "Não foi possível ler \(nome).json: \(String(describing: erro))"
        }
    }
}

struct BundleDadosRepository: DadosRepositoryProtocol {
    let bundle: Bundle = .main

    func carregar() throws -> ConjuntoDeDados {
        ConjuntoDeDados(jogos: try ler("jogos"), metadados: try ler("metadados"))
    }

    private func ler<T: Decodable>(_ nome: String) throws -> T {
        guard let url = bundle.url(forResource: nome, withExtension: "json") else {
            throw ErroDados.arquivoNaoEncontrado(nome)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: Data(contentsOf: url))
        } catch {
            throw ErroDados.falhaDecodificacao(nome, error)
        }
    }
}
