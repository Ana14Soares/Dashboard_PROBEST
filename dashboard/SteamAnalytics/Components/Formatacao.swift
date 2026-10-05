// Components/Formatacao.swift
// Números sempre no formato brasileiro, mesmo com o Mac ou o iPhone em inglês.
import Foundation

enum Fmt {
    static let br = Locale(identifier: "pt_BR")

    /// 27075 → "27.075"
    static func num(_ v: Int) -> String { v.formatted(.number.locale(br)) }

    /// 78.24 → "78,2"
    static func dec(_ v: Double, _ casas: Int = 1) -> String {
        v.formatted(.number.precision(.fractionLength(casas)).locale(br))
    }

    /// 78.24 → "78,2%"
    static func pct(_ v: Double, _ casas: Int = 1) -> String { dec(v, casas) + "%" }

    /// 4.79 → "£4,79"
    static func libra(_ v: Double) -> String { "£" + dec(v, 2) }

    /// -5.0 → "−5,0 p.p."
    static func pp(_ v: Double) -> String {
        let sinal = v > 0 ? "+" : (v < 0 ? "−" : "")
        return sinal + dec(abs(v), 1) + " p.p."
    }

    /// 75000000 → "75 mi"
    static func compacto(_ v: Double) -> String {
        v.formatted(.number.notation(.compactName).locale(br))
    }

    // Versões para valores opcionais: "—" quando o recorte não tem jogos no grupo.
    static func pct(talvez v: Double?) -> String { v.map { pct($0) } ?? "—" }
    static func libra(talvez v: Double?) -> String { v.map { libra($0) } ?? "—" }
    static func pp(talvez v: Double?) -> String { v.map { pp($0) } ?? "—" }
}
