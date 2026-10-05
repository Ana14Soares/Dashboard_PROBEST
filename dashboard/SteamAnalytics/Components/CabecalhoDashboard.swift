// Components/CabecalhoDashboard.swift
import SwiftUI

/// Faixa azul no topo de cada página: título, pergunta e o recorte em uso.
/// Mostrar o filtro ativo evita apresentar um número filtrado como se fosse o total.
struct CabecalhoDashboard: View {
    let pagina: Pagina
    let filtro: FiltroGlobal
    let recorte: Recorte

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: pagina.icone)
                .font(.title)
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(pagina.rawValue) · Steam 1997–2019")
                    .font(.title2.bold())
                Text(pagina.pergunta)
                    .font(.subheadline)
                    .opacity(0.85)
            }
            Spacer(minLength: 16)
            VStack(alignment: .trailing, spacing: 2) {
                Label(filtro.descricao, systemImage: filtro.ativo
                      ? "line.3.horizontal.decrease.circle.fill"
                      : "line.3.horizontal.decrease.circle")
                    .font(.caption.bold())
                Text("\(Fmt.num(recorte.catalogo.count)) jogos · \(Fmt.num(recorte.base.count)) com ≥ \(recorte.minAvaliacoes) avaliações")
                    .font(.caption)
                    .opacity(0.85)
            }
            .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(.white)
        .padding()
        .background(Paleta.titulo.gradient, in: RoundedRectangle(cornerRadius: 16))
    }
}
