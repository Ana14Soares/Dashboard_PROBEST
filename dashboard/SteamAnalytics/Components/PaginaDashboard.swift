// Components/PaginaDashboard.swift
import SwiftUI

/// Molde comum das páginas: cabeçalho, linha de KPIs, grade de gráficos e rodapé.
struct PaginaDashboard<Graficos: View>: View {
    let dash: Dashboard
    let recorte: Recorte
    let pagina: Pagina
    let kpis: [KPI]
    let graficos: Graficos

    init(dash: Dashboard, recorte: Recorte, pagina: Pagina, kpis: [KPI],
         @ViewBuilder graficos: () -> Graficos) {
        self.dash = dash
        self.recorte = recorte
        self.pagina = pagina
        self.kpis = kpis
        self.graficos = graficos()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CabecalhoDashboard(pagina: pagina, filtro: dash.filtro, recorte: recorte)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12, alignment: .top)],
                          spacing: 12) {
                    ForEach(kpis) { KPICard(kpi: $0) }
                }

                if recorte.base.isEmpty {
                    ContentUnavailableView("Nenhum jogo neste recorte",
                                           systemImage: "line.3.horizontal.decrease.circle",
                                           description: Text("Mude ou redefina os filtros na barra lateral."))
                } else {
                    GradeAdaptativa { graficos }
                }

                RodapeMetodologico(meta: dash.meta)
            }
            .padding()
        }
        .background(Paleta.fundo)
        .navigationTitle(pagina.rawValue)
    }
}
