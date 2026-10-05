// Components/BarraLateral.swift
import SwiftUI

/// Navegação entre páginas em cima e filtros embaixo, como a coluna
/// lateral do painel de referência.
struct BarraLateral: View {
    @Binding var pagina: Pagina?
    @Binding var filtro: FiltroGlobal

    var body: some View {
        List(selection: $pagina) {
            Section {
                ForEach(Pagina.allCases) { p in
                    Label(p.rawValue, systemImage: p.icone).tag(p)
                }
            } header: {
                Label("Steam Analytics", systemImage: "gamecontroller.fill")
                    .font(.headline)
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            PainelFiltros(filtro: $filtro)
                .padding(10)
        }
    }
}

struct PainelFiltros: View {
    @Binding var filtro: FiltroGlobal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Filtros", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.headline)
                Spacer()
                Button("Redefinir") {
                    withAnimation { filtro = FiltroGlobal() }
                }
                .buttonStyle(.borderless)
                .font(.caption)
                .disabled(!filtro.ativo)
            }

            CampoFiltro(titulo: "Período de lançamento") {
                Picker("Período de lançamento", selection: $filtro.periodo) {
                    Text("Todos").tag(Periodo?.none)
                    ForEach(Periodo.allCases) { Text($0.rawValue).tag(Optional($0)) }
                }
            }
            CampoFiltro(titulo: "Gênero") {
                Picker("Gênero", selection: $filtro.genero) {
                    Text("Todos").tag(String?.none)
                    ForEach(generosPrincipais, id: \.self) { Text($0).tag(Optional($0)) }
                }
            }
            CampoFiltro(titulo: "Preço") {
                Picker("Preço", selection: $filtro.preco) {
                    ForEach(FiltroGlobal.OpcaoPreco.allCases) { Text($0.rawValue).tag($0) }
                }
            }
            CampoFiltro(titulo: "Plataforma") {
                Picker("Plataforma", selection: $filtro.plataforma) {
                    ForEach(FiltroGlobal.OpcaoPlataforma.allCases) { Text($0.rawValue).tag($0) }
                }
            }
            CampoFiltro(titulo: "Conquistas") {
                Picker("Conquistas", selection: $filtro.conquistas) {
                    ForEach(FiltroGlobal.OpcaoConquistas.allCases) { Text($0.rawValue).tag($0) }
                }
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.separator))
    }
}

private struct CampoFiltro<Conteudo: View>: View {
    let titulo: String
    @ViewBuilder let conteudo: Conteudo

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.secondary)
            conteudo
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
