import SwiftUI
import CryptoKit

// MARK: - Theme

enum PFTheme {
    static let bg = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let surface = Color(red: 0.16, green: 0.16, blue: 0.19)
    static let surfaceHover = Color(red: 0.20, green: 0.20, blue: 0.24)
    static let border = Color.white.opacity(0.08)
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.55)
    static let accent = Color(red: 0.40, green: 0.65, blue: 1.0)
    static let success = Color(red: 0.30, green: 0.78, blue: 0.50)
    static let warning = Color(red: 1.0, green: 0.60, blue: 0.25)
    static let error = Color(red: 0.95, green: 0.35, blue: 0.35)
    static let categoryCase = Color(red: 0.55, green: 0.75, blue: 1.0)
    static let categoryEncode = Color(red: 0.70, green: 0.55, blue: 1.0)
    static let categoryFormat = Color(red: 0.50, green: 0.85, blue: 0.65)
    static let categoryHash = Color(red: 1.0, green: 0.65, blue: 0.45)
    static let categoryStats = Color(red: 0.85, green: 0.55, blue: 0.75)
}

// MARK: - Transform Types

enum TransformCategory: String, CaseIterable {
    case all = "All"
    case caseChange = "Case"
    case encode = "Encode"
    case format = "Format"
    case hash = "Hash"
    case stats = "Stats"

    var color: Color {
        switch self {
        case .all: return PFTheme.accent
        case .caseChange: return PFTheme.categoryCase
        case .encode: return PFTheme.categoryEncode
        case .format: return PFTheme.categoryFormat
        case .hash: return PFTheme.categoryHash
        case .stats: return PFTheme.categoryStats
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .caseChange: return "textformat.size"
        case .encode: return "lock.shield"
        case .format: return "text.alignleft"
        case .hash: return "number"
        case .stats: return "chart.bar"
        }
    }
}

struct Transform: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: TransformCategory
    let apply: (String) -> String
}

// MARK: - Transform Definitions

enum Transforms {
    static let all: [Transform] = [
        // Case
        Transform(name: "UPPERCASE", icon: "textformat.size.larger", category: .caseChange) { $0.uppercased() },
        Transform(name: "lowercase", icon: "textformat.size.smaller", category: .caseChange) { $0.lowercased() },
        Transform(name: "Title Case", icon: "textformat", category: .caseChange) { titleCase($0) },
        Transform(name: "camelCase", icon: "chevron.left.forwardslash.chevron.right", category: .caseChange) { camelCase($0) },
        Transform(name: "snake_case", icon: "arrow.right", category: .caseChange) { snakeCase($0) },
        Transform(name: "kebab-case", icon: "minus", category: .caseChange) { kebabCase($0) },
        Transform(name: "CONSTANT_CASE", icon: "textformat.size.larger", category: .caseChange) { constantCase($0) },
        Transform(name: "Capitalize First", icon: "textformat.abc", category: .caseChange) { capitalizeFirst($0) },

        // Encode/Decode
        Transform(name: "Base64 Encode", icon: "lock", category: .encode) { base64Encode($0) },
        Transform(name: "Base64 Decode", icon: "lock.open", category: .encode) { base64Decode($0) },
        Transform(name: "URL Encode", icon: "link", category: .encode) { urlEncode($0) },
        Transform(name: "URL Decode", icon: "link.badge.plus", category: .encode) { urlDecode($0) },
        Transform(name: "HTML Encode", icon: "chevron.left.forwardslash.chevron.right", category: .encode) { htmlEncode($0) },
        Transform(name: "HTML Decode", icon: "chevron.left.forwardslash.chevron.right", category: .encode) { htmlDecode($0) },
        Transform(name: "Unicode Escape", icon: "u.square", category: .encode) { unicodeEscape($0) },

        // Format
        Transform(name: "JSON Pretty", icon: "curlybraces", category: .format) { jsonPretty($0) },
        Transform(name: "JSON Minify", icon: "curlybraces", category: .format) { jsonMinify($0) },
        Transform(name: "Sort Lines", icon: "arrow.up.arrow.down", category: .format) { sortLines($0) },
        Transform(name: "Unique Lines", icon: "line.3.horizontal.decrease", category: .format) { uniqueLines($0) },
        Transform(name: "Reverse Lines", icon: "arrow.uturn.down", category: .format) { reverseLines($0) },
        Transform(name: "Reverse Text", icon: "arrow.uturn.left", category: .format) { String($0.reversed()) },
        Transform(name: "Trim Whitespace", icon: "scissors", category: .format) { trimWhitespace($0) },
        Transform(name: "Remove Blank Lines", icon: "text.line.first.and.arrowtriangle.forward", category: .format) { removeBlankLines($0) },
        Transform(name: "Add Line Numbers", icon: "list.number", category: .format) { addLineNumbers($0) },
        Transform(name: "Remove Duplicates", icon: "xmark.circle", category: .format) { removeDuplicateWords($0) },
        Transform(name: "Wrap in Quotes", icon: "text.quote", category: .format) { "\"\($0)\"" },
        Transform(name: "Extract URLs", icon: "link", category: .format) { extractURLs($0) },
        Transform(name: "Extract Emails", icon: "envelope", category: .format) { extractEmails($0) },
        Transform(name: "Strip HTML", icon: "chevron.left.forwardslash.chevron.right", category: .format) { stripHTML($0) },

        // Hash
        Transform(name: "MD5", icon: "number", category: .hash) { md5($0) },
        Transform(name: "SHA-1", icon: "number.circle", category: .hash) { sha1($0) },
        Transform(name: "SHA-256", icon: "number.square", category: .hash) { sha256($0) },

        // Stats (display-only, non-destructive)
        Transform(name: "Character Count", icon: "textformat.123", category: .stats) { "\($0.count) characters" },
        Transform(name: "Word Count", icon: "doc.text", category: .stats) {
            let words = $0.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
            return "\(words) words"
        },
        Transform(name: "Line Count", icon: "list.bullet", category: .stats) {
            let lines = $0.components(separatedBy: .newlines).count
            return "\(lines) lines"
        },
        Transform(name: "Byte Size", icon: "externaldrive", category: .stats) {
            let bytes = $0.utf8.count
            if bytes < 1024 { return "\(bytes) B" }
            else if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
            else { return String(format: "%.1f MB", Double(bytes) / (1024 * 1024)) }
        },
        Transform(name: "Reading Time", icon: "clock", category: .stats) {
            let words = $0.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
            let minutes = max(1, words / 200)
            return "~\(minutes) min read (\(words) words)"
        },
    ]

    // MARK: - Case Transforms

    static func titleCase(_ s: String) -> String {
        s.components(separatedBy: " ").map { word in
            guard let first = word.first else { return "" }
            return String(first).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }

    static func camelCase(_ s: String) -> String {
        let words = splitIntoWords(s)
        guard let first = words.first else { return "" }
        return first.lowercased() + words.dropFirst().map { $0.capitalized }.joined()
    }

    static func snakeCase(_ s: String) -> String {
        splitIntoWords(s).map { $0.lowercased() }.joined(separator: "_")
    }

    static func kebabCase(_ s: String) -> String {
        splitIntoWords(s).map { $0.lowercased() }.joined(separator: "-")
    }

    static func constantCase(_ s: String) -> String {
        splitIntoWords(s).map { $0.uppercased() }.joined(separator: "_")
    }

    static func capitalizeFirst(_ s: String) -> String {
        guard let first = s.first else { return "" }
        return String(first).uppercased() + s.dropFirst()
    }

    static func splitIntoWords(_ s: String) -> [String] {
        // Handle camelCase, snake_case, kebab-case, spaces, etc.
        var words: [String] = []
        var current = ""
        for char in s {
            if char == "_" || char == "-" || char == " " || char == "." {
                if !current.isEmpty { words.append(current); current = "" }
            } else if char.isUppercase && !current.isEmpty && current.last?.isUppercase == false {
                words.append(current); current = String(char)
            } else {
                current.append(char)
            }
        }
        if !current.isEmpty { words.append(current) }
        return words
    }

    // MARK: - Encode/Decode

    static func base64Encode(_ s: String) -> String {
        Data(s.utf8).base64EncodedString()
    }

    static func base64Decode(_ s: String) -> String {
        guard let data = Data(base64Encoded: s.trimmingCharacters(in: .whitespacesAndNewlines)),
              let decoded = String(data: data, encoding: .utf8) else {
            return "[Invalid Base64]"
        }
        return decoded
    }

    static func urlEncode(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
    }

    static func urlDecode(_ s: String) -> String {
        s.removingPercentEncoding ?? s
    }

    static func htmlEncode(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
         .replacingOccurrences(of: "'", with: "&#39;")
    }

    static func htmlDecode(_ s: String) -> String {
        s.replacingOccurrences(of: "&amp;", with: "&")
         .replacingOccurrences(of: "&lt;", with: "<")
         .replacingOccurrences(of: "&gt;", with: ">")
         .replacingOccurrences(of: "&quot;", with: "\"")
         .replacingOccurrences(of: "&#39;", with: "'")
    }

    static func unicodeEscape(_ s: String) -> String {
        s.unicodeScalars.map { scalar in
            if scalar.value < 128 { return String(scalar) }
            return String(format: "\\u{%04X}", scalar.value)
        }.joined()
    }

    // MARK: - Format

    static func jsonPretty(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let result = String(data: pretty, encoding: .utf8) else {
            return "[Invalid JSON]"
        }
        return result
    }

    static func jsonMinify(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let mini = try? JSONSerialization.data(withJSONObject: obj),
              let result = String(data: mini, encoding: .utf8) else {
            return "[Invalid JSON]"
        }
        return result
    }

    static func sortLines(_ s: String) -> String {
        s.components(separatedBy: .newlines).sorted().joined(separator: "\n")
    }

    static func uniqueLines(_ s: String) -> String {
        var seen = Set<String>()
        return s.components(separatedBy: .newlines).filter { seen.insert($0).inserted }.joined(separator: "\n")
    }

    static func reverseLines(_ s: String) -> String {
        s.components(separatedBy: .newlines).reversed().joined(separator: "\n")
    }

    static func trimWhitespace(_ s: String) -> String {
        s.components(separatedBy: .newlines)
         .map { $0.trimmingCharacters(in: .whitespaces) }
         .joined(separator: "\n")
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func removeBlankLines(_ s: String) -> String {
        s.components(separatedBy: .newlines)
         .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
         .joined(separator: "\n")
    }

    static func addLineNumbers(_ s: String) -> String {
        let lines = s.components(separatedBy: .newlines)
        let width = String(lines.count).count
        return lines.enumerated().map { i, line in
            String(format: "%\(width)d  %@", i + 1, line)
        }.joined(separator: "\n")
    }

    static func removeDuplicateWords(_ s: String) -> String {
        var seen = Set<String>()
        return s.split(separator: " ").filter { seen.insert(String($0)).inserted }.joined(separator: " ")
    }

    static func extractURLs(_ s: String) -> String {
        let pattern = "https?://[^\\s<>\"'\\)\\]]*"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
        let range = NSRange(s.startIndex..., in: s)
        let matches = regex.matches(in: s, range: range)
        let urls = matches.compactMap { Range($0.range, in: s).map { String(s[$0]) } }
        return urls.isEmpty ? "[No URLs found]" : urls.joined(separator: "\n")
    }

    static func extractEmails(_ s: String) -> String {
        let pattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
        let range = NSRange(s.startIndex..., in: s)
        let matches = regex.matches(in: s, range: range)
        let emails = matches.compactMap { Range($0.range, in: s).map { String(s[$0]) } }
        return emails.isEmpty ? "[No emails found]" : emails.joined(separator: "\n")
    }

    static func stripHTML(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let attrStr = try? NSAttributedString(
                  data: data,
                  options: [.documentType: NSAttributedString.DocumentType.html,
                            .characterEncoding: String.Encoding.utf8.rawValue],
                  documentAttributes: nil) else {
            // Fallback: regex strip
            return s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        }
        return attrStr.string
    }

    // MARK: - Hash

    static func md5(_ s: String) -> String {
        Insecure.MD5.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    static func sha1(_ s: String) -> String {
        Insecure.SHA1.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    static func sha256(_ s: String) -> String {
        SHA256.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Clipboard Manager

@Observable
class ClipboardManager {
    var clipboardText: String = ""
    var hasClipboard: Bool = false
    var result: String? = nil
    var lastTransformName: String? = nil
    var copied: Bool = false
    var searchQuery: String = ""
    var selectedCategory: TransformCategory = .all
    private var timer: Timer?

    init() {
        readClipboard()
        startPolling()
    }

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.readClipboard()
        }
    }

    func readClipboard() {
        if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
            if text != clipboardText {
                clipboardText = text
                hasClipboard = true
                // Clear result when clipboard changes
                result = nil
                lastTransformName = nil
                copied = false
            }
        } else {
            clipboardText = ""
            hasClipboard = false
            result = nil
            lastTransformName = nil
            copied = false
        }
    }

    func applyTransform(_ transform: Transform) {
        let output = transform.apply(clipboardText)
        result = output
        lastTransformName = transform.name
        copied = false
    }

    func copyResult() {
        guard let result else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(result, forType: .string)
        copied = true
        // Update clipboard text to match
        clipboardText = result
    }

    var filteredTransforms: [Transform] {
        var transforms = Transforms.all
        if selectedCategory != .all {
            transforms = transforms.filter { $0.category == selectedCategory }
        }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            transforms = transforms.filter { $0.name.lowercased().contains(q) }
        }
        return transforms
    }

    var previewText: String {
        let text = clipboardText
        if text.count <= 120 { return text }
        return String(text.prefix(120)) + "..."
    }
}

// MARK: - Transform Row View

struct TransformRow: View {
    let transform: Transform
    let onApply: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onApply) {
            HStack(spacing: 8) {
                Image(systemName: transform.icon)
                    .font(.system(size: 11))
                    .foregroundStyle(transform.category.color)
                    .frame(width: 16)

                Text(transform.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PFTheme.textPrimary)

                Spacer()

                Text(transform.category.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(transform.category.color.opacity(0.7))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(transform.category.color.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isHovered ? PFTheme.surfaceHover : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: TransformCategory
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 3) {
                Image(systemName: category.icon)
                    .font(.system(size: 9))
                Text(category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                if category != .all {
                    Text("\(count)")
                        .font(.system(size: 9))
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : PFTheme.textSecondary)
                }
            }
            .foregroundStyle(isSelected ? .white : PFTheme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? category.color.opacity(0.6) : PFTheme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? category.color.opacity(0.3) : PFTheme.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Result View

struct ResultView: View {
    let transformName: String
    let result: String
    let copied: Bool
    let onCopy: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(PFTheme.success)
                    .font(.system(size: 12))
                Text(transformName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(PFTheme.textPrimary)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(PFTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            ScrollView {
                Text(result)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(PFTheme.textPrimary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 120)

            HStack {
                Text("\(result.count) chars")
                    .font(.system(size: 9))
                    .foregroundStyle(PFTheme.textSecondary)
                Spacer()
                Button(action: onCopy) {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10))
                        Text(copied ? "Copied!" : "Copy to Clipboard")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(copied ? PFTheme.success : PFTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(PFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(PFTheme.success.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Content View

struct ContentView: View {
    @Bindable var manager: ClipboardManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "scissors")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PFTheme.accent)
                Text("PasteForge")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(PFTheme.textPrimary)
                Spacer()
                Text("v0.1.0")
                    .font(.system(size: 9))
                    .foregroundStyle(PFTheme.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(PFTheme.surface.opacity(0.5))

            Divider().overlay(PFTheme.border)

            if !manager.hasClipboard {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 32))
                        .foregroundStyle(PFTheme.textSecondary.opacity(0.3))
                    Text("No text on clipboard")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(PFTheme.textSecondary)
                    Text("Copy some text, then open PasteForge\nto transform it.")
                        .font(.system(size: 11))
                        .foregroundStyle(PFTheme.textSecondary.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        // Clipboard preview
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "doc.on.clipboard.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(PFTheme.accent)
                                Text("Clipboard")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(PFTheme.textSecondary)
                                Spacer()
                                Text("\(manager.clipboardText.count) chars")
                                    .font(.system(size: 9))
                                    .foregroundStyle(PFTheme.textSecondary.opacity(0.5))
                            }

                            Text(manager.previewText)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(PFTheme.textPrimary.opacity(0.8))
                                .lineLimit(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(10)
                        .background(PFTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(PFTheme.accent.opacity(0.15), lineWidth: 0.5)
                        )

                        // Result (if any)
                        if let result = manager.result, let name = manager.lastTransformName {
                            ResultView(
                                transformName: name,
                                result: result,
                                copied: manager.copied,
                                onCopy: { manager.copyResult() },
                                onDismiss: {
                                    manager.result = nil
                                    manager.lastTransformName = nil
                                    manager.copied = false
                                }
                            )
                        }

                        // Search
                        HStack(spacing: 6) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 11))
                                .foregroundStyle(PFTheme.textSecondary)
                            TextField("Search transforms...", text: $manager.searchQuery)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12))
                                .foregroundStyle(PFTheme.textPrimary)
                            if !manager.searchQuery.isEmpty {
                                Button(action: { manager.searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(PFTheme.textSecondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(8)
                        .background(PFTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        // Category chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(TransformCategory.allCases, id: \.self) { cat in
                                    CategoryChip(
                                        category: cat,
                                        isSelected: manager.selectedCategory == cat,
                                        count: Transforms.all.filter { $0.category == cat }.count,
                                        onTap: { manager.selectedCategory = cat }
                                    )
                                }
                            }
                        }

                        // Transform list
                        let transforms = manager.filteredTransforms
                        if transforms.isEmpty {
                            Text("No matching transforms")
                                .font(.system(size: 11))
                                .foregroundStyle(PFTheme.textSecondary)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(transforms) { transform in
                                    TransformRow(transform: transform) {
                                        manager.applyTransform(transform)
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                }
                .frame(maxHeight: .infinity)
            }

            Divider().overlay(PFTheme.border)

            // Footer
            HStack {
                Text("\(Transforms.all.count) transforms")
                    .font(.system(size: 9))
                    .foregroundStyle(PFTheme.textSecondary.opacity(0.4))
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .font(.system(size: 9))
                    .foregroundStyle(PFTheme.textSecondary.opacity(0.4))
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(PFTheme.surface.opacity(0.5))
        }
        .background(PFTheme.bg)
        .frame(width: 360, height: 520)
    }
}

// MARK: - App

@main
struct PasteForgeApp: App {
    @State private var manager = ClipboardManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView(manager: manager)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "scissors")
                if manager.hasClipboard {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .foregroundStyle(.green)
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
