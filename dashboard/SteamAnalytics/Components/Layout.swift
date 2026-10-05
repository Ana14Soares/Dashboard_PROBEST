// Components/Layout.swift
import SwiftUI

extension EnvironmentValues {
    /// true quando a área de conteúdo é estreita (iPhone, ou janela do Mac bem estreita).
    @Entry var compacto: Bool = false
}

private struct MedeLargura: ViewModifier {
    @State private var compacto = false

    func body(content: Content) -> some View {
        content
            .environment(\.compacto, compacto)
            .onGeometryChange(for: Bool.self) { $0.size.width < 640 } action: { compacto = $0 }
    }
}

extension View {
    func larguraAdaptativa() -> some View { modifier(MedeLargura()) }
}

/// Grade de painéis: 2 colunas numa janela de Mac, 1 coluna quando estreita.
struct GradeAdaptativa<Conteudo: View>: View {
    var minimo: CGFloat = 460
    @ViewBuilder let conteudo: Conteudo

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minimo), spacing: 16, alignment: .top)],
                  alignment: .leading, spacing: 16) {
            conteudo
        }
    }
}

/// Cartão branco de um gráfico: título descritivo, subtítulo curto e o gráfico.
struct Painel<Conteudo: View>: View {
    let titulo: String
    var subtitulo: String? = nil
    @ViewBuilder let conteudo: Conteudo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(titulo)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitulo {
                    Text(subtitulo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            conteudo
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Paleta.softLilac.opacity(0.5)))
    }
}

/// Cores com significado fixo em todo o app.
enum Paleta {
    // Paleta: Raspberry Rose, Soft Lilac, Blueberry Milk, Lemon Cream

    /// Raspberry Rose #F2619C — cabeçalho e destaques fortes.
    static let raspberryRose = Color(red: 0.949, green: 0.380, blue: 0.612)
    /// Soft Lilac #E7BEF8
    static let softLilac = Color(red: 0.906, green: 0.745, blue: 0.973)
    /// Blueberry Milk #93ABD9
    static let blueberryMilk = Color(red: 0.576, green: 0.671, blue: 0.851)
    /// Lemon Cream #EDE986
    static let lemonCream = Color(red: 0.929, green: 0.914, blue: 0.525)

    /// Fundo do cabeçalho: Raspberry Rose escurecido para bom contraste com texto branco.
    static let titulo = Color(red: 0.72, green: 0.22, blue: 0.42)
    /// Fundo das páginas, atrás dos cartões brancos.
    static let fundo = lemonCream.opacity(0.12)
    /// Numa comparação: o grupo com o maior valor…
    static let maior = blueberryMilk
    /// …o grupo com o menor valor…
    static let menor = raspberryRose
    /// …e os intermediários.
    static let neutro = softLilac

    static func cor(_ faixa: FaixaAvaliacao) -> Color {
        switch faixa {
        case .positiva: blueberryMilk
        case .mista:    lemonCream
        case .negativa: raspberryRose
        }
    }

    /// Cor de texto legível sobre cada cor da paleta. Cores claras precisam de texto escuro.
    static func textoSobre(_ cor: Color) -> Color {
        // Lemon Cream e Soft Lilac são claras → texto escuro; as demais → branco.
        if cor == lemonCream || cor == softLilac { return .black.opacity(0.7) }
        return .white
    }
}
