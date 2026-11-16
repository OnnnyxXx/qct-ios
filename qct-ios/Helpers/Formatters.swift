//
//  Formatters.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import Foundation

enum Formatters {

    static func starName(index: Int, rating: Double) -> String {
        let diff = rating - Double(index)
        if diff >= 1 { return "star.fill" }
        if diff >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }

    static func double(_ value: Double?, unit: String = "") -> String {
        guard let value else { return "—" }
        return String(format: "%g", value) + unit
    }

    static func date(_ iso: String?) -> String {
        guard let iso else { return "—" }
        let isoFmt = ISO8601DateFormatter()
        isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var parsed = isoFmt.date(from: iso)
        if parsed == nil {
            isoFmt.formatOptions = [.withInternetDateTime]
            parsed = isoFmt.date(from: iso)
        }
        guard let date = parsed else { return iso }
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale(identifier: "ru_RU")
        return df.string(from: date)
    }

    static func dimensions(width: Double?, height: Double?, length: Double?) -> String {
        let w = width.map { String(format: "%g", $0) } ?? "—"
        let h = height.map { String(format: "%g", $0) } ?? "—"
        let l = length.map { String(format: "%g", $0) } ?? "—"
        if w == "—" && h == "—" && l == "—" { return "—" }
        return "\(w) × \(h) × \(l) см"
    }
}
