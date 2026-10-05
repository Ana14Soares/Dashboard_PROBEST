// Models/Metadados.swift
import Foundation

struct Metadados: Codable, Sendable {
    let geradoEm: String
    let fonte: String
    let totalJogos: Int
    let minAvaliacoes: Int     // 50: corte para tudo que usa % positivas
    let moeda: String          // "GBP"
    let anoMin: Int
    let anoMax: Int
    let anoParcial: Int        // 2019: coleta feita no meio do ano
}
