// Components/KPICard.swift
import SwiftUI

/// Um indicador: valor grande em cima e uma métrica de apoio embaixo,
/// como os cartões do painel de referência.
struct KPI: Identifiable {
    let titulo: String
    let valor: String
    let icone: String
    var detalhe: String? = nil
    var detalheValor: String? = nil
    var cor: Color = .primary
    var id: String { titulo }
}

struct KPICard: View {
    let kpi: KPI

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Label(kpi.titulo, systemImage: kpi.icone)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(minHeight: 30, alignment: .topLeading)
                Text(kpi.valor)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(kpi.cor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }
            .padding(12)

            if let detalhe = kpi.detalhe, let valor = kpi.detalheValor {
                Divider()
                HStack(spacing: 4) {
                    Text(detalhe).foregroundStyle(.secondary)
                    Text(valor).bold()
                }
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.separator))
        .accessibilityElement(children: .combine)
    }
}
