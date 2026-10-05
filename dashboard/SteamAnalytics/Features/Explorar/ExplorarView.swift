// Features/Explorar/ExplorarView.swift
// Tabela dos jogos do recorte (base de avaliação), com busca, ordenação e detalhe.
import SwiftUI

enum OrdenacaoJogo: String, CaseIterable, Identifiable {
    case avaliacoes = "Mais avaliados"
    case avaliacao  = "Melhor avaliados"
    case donos      = "Mais donos"
    case preco      = "Mais caros"
    var id: String { rawValue }
}

struct ExplorarView: View {
    let dash: Dashboard
    @State private var busca = ""
    @State private var ordenacao: OrdenacaoJogo = .avaliacoes
    @State private var selecionado: Jogo.ID?

    var body: some View {
        let r = dash.recorte
        let jogos = lista(r.base)
//
//        VStack(alignment: .leading, spacing: 12) {
//            CabecalhoDashboard(pagina: .explorar, filtro: dash.filtro, recorte: r)
//            Text("\(Fmt.num(jogos.count)) jogos com ≥ \(r.minAvaliacoes) avaliações neste recorte")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//            Table(jogos, selection: $selecionado) {
//                TableColumn("Jogo", value: \.nome)
//                TableColumn("Ano") { Text(String($0.ano)) }
//                    .width(50)
//                TableColumn("Gêneros") { Text($0.generos.isEmpty ? "—" : $0.generos.joined(separator: ", ")) }
//                    .width(min: 110, ideal: 160)
//                TableColumn("% positivas") { jogo in
//                    Text(Fmt.pct(jogo.pctPositivas))
//                        .monospacedDigit()
//                        .foregroundStyle(Paleta.cor(jogo.faixaAvaliacao))
//                }
//                .width(90)
//                TableColumn("Avaliações") { Text(Fmt.num($0.totalAvaliacoes)).monospacedDigit() }
//                    .width(95)
//                TableColumn("Donos (est.)") { Text(Fmt.compacto($0.donosMedio)) }
//                    .width(90)
//                TableColumn("Preço") { Text($0.gratuito ? "Gratuito" : Fmt.libra($0.preco)) }
//                    .width(80)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//        .padding()
//        .background(Paleta.fundo)
////        .navigationTitle(Pagina.explorar.rawValue)
//        .searchable(text: $busca, prompt: "Buscar jogo")
//        .toolbar {
//            ToolbarItem {
//                Picker("Ordenar", selection: $ordenacao) {
//                    ForEach(OrdenacaoJogo.allCases) { Text($0.rawValue).tag($0) }
//                }
//                .pickerStyle(.menu)
//            }
//        }
//        .inspector(isPresented: mostrandoDetalhe) {
//            if let id = selecionado, let jogo = dash.jogos.first(where: { $0.id == id }) {
//                DetalheJogo(jogo: jogo)
//                    .inspectorColumnWidth(min: 260, ideal: 300, max: 360)
//            }
//        }
    }

    private var mostrandoDetalhe: Binding<Bool> {
        Binding(get: { selecionado != nil }, set: { if !$0 { selecionado = nil } })
    }

    private func lista(_ base: [Jogo]) -> [Jogo] {
        let achados = busca.isEmpty ? base : base.filter { $0.nome.localizedCaseInsensitiveContains(busca) }
        switch ordenacao {
        case .avaliacoes: return achados   // o JSON já vem ordenado por nº de avaliações
        case .avaliacao:  return achados.sorted { $0.pctPositivas > $1.pctPositivas }
        case .donos:      return achados.sorted { $0.donosMedio > $1.donosMedio }
        case .preco:      return achados.sorted { $0.preco > $1.preco }
        }
    }
}

struct DetalheJogo: View {
    let jogo: Jogo

    var body: some View {
        Form {
            Section(jogo.nome) {
                LabeledContent("Lançamento", value: String(jogo.ano))
                LabeledContent("Preço", value: jogo.gratuito ? "Gratuito" : Fmt.libra(jogo.preco))
                LabeledContent("Gêneros", value: jogo.generos.isEmpty ? "—" : jogo.generos.joined(separator: ", "))
                LabeledContent("Plataformas", value: jogo.plataformas.map(\.capitalized).joined(separator: ", "))
                LabeledContent("Conquistas", value: Fmt.num(jogo.conquistas))
                LabeledContent("Donos (faixa)",
                               value: "\(Fmt.compacto(Double(jogo.donosMin)))–\(Fmt.compacto(Double(jogo.donosMax)))")
                LabeledContent("Indie", value: jogo.indie ? "Sim" : "Não")
            }
            Section("Avaliações") {
                LabeledContent("Positivas", value: Fmt.pct(jogo.pctPositivas))
                LabeledContent("Total", value: Fmt.num(jogo.totalAvaliacoes))
                LabeledContent("Faixa", value: jogo.faixaAvaliacao.rawValue)
            }
        }
        .formStyle(.grouped)
    }
}
