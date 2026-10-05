// Components/RodapeMetodologico.swift
import SwiftUI

struct RodapeMetodologico: View {
    let meta: Metadados

    var body: some View {
        Text("Percentuais de avaliação usam só jogos com pelo menos \(meta.minAvaliacoes) avaliações; contagens, preços e donos usam o catálogo inteiro (\(Fmt.num(meta.totalJogos)) jogos). Preços em \(meta.moeda). Donos são faixas estimadas pelo SteamSpy. \(String(meta.anoParcial)) está incompleto (coleta no meio do ano). Fonte: \(meta.fonte). Dados gerados em \(meta.geradoEm).")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
    }
}
