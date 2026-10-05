//// SteamAnalyticsTests/RecorteTests.swift  (target de testes, Swift Testing)
//import Testing
//@testable import SteamAnalytics
//
//@MainActor
//struct RecorteTests {
//    let dash = Dashboard(try! BundleDadosRepository().carregar())
//
//    @Test func semFiltroBateComONotebook() {
//        let r = dash.recorte
//        #expect(r.catalogo.count == 27_075)
//        #expect(r.base.count == 11_818)
//        let mediana = Estat.mediana(r.base.map(\.pctPositivas)) ?? 0
//        #expect(abs(mediana - 78.18) < 0.01)
//    }
//
//    @Test func filtroDeGeneroValeParaTodasAsBases() {
//        dash.filtro.genero = "Action"
//        let r = dash.recorte
//        #expect(r.catalogo.allSatisfy { $0.generos.contains("Action") })
//        #expect(r.base.allSatisfy { $0.totalAvaliacoes >= 50 })
//    }
//}
