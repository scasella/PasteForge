import Foundation
import CryptoKit

// Minimal transform test harness — copy logic from PasteForge.swift

enum T {
    static func splitIntoWords(_ s: String) -> [String] {
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

    static func titleCase(_ s: String) -> String {
        s.components(separatedBy: " ").map { word in
            guard let first = word.first else { return "" }
            return String(first).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }

    static func base64Encode(_ s: String) -> String { Data(s.utf8).base64EncodedString() }
    static func base64Decode(_ s: String) -> String {
        guard let data = Data(base64Encoded: s.trimmingCharacters(in: .whitespacesAndNewlines)),
              let decoded = String(data: data, encoding: .utf8) else { return "[Invalid Base64]" }
        return decoded
    }

    static func urlEncode(_ s: String) -> String { s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s }
    static func urlDecode(_ s: String) -> String { s.removingPercentEncoding ?? s }

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

    static func addLineNumbers(_ s: String) -> String {
        let lines = s.components(separatedBy: .newlines)
        let width = String(lines.count).count
        return lines.enumerated().map { i, line in
            String(format: "%\(width)d  %@", i + 1, line)
        }.joined(separator: "\n")
    }

    static func extractURLs(_ s: String) -> String {
        let pattern = "https?://[^\\s<>\"'\\)\\]]*"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
        let range = NSRange(s.startIndex..., in: s)
        let matches = regex.matches(in: s, range: range)
        let urls = matches.compactMap { Range($0.range, in: s).map { String(s[$0]) } }
        return urls.isEmpty ? "[No URLs found]" : urls.joined(separator: "\n")
    }

    static func md5(_ s: String) -> String {
        Insecure.MD5.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    static func sha1(_ s: String) -> String {
        Insecure.SHA1.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    static func sha256(_ s: String) -> String {
        SHA256.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    static func jsonPretty(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let result = String(data: pretty, encoding: .utf8) else { return "[Invalid JSON]" }
        return result
    }

    static func jsonMinify(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let mini = try? JSONSerialization.data(withJSONObject: obj),
              let result = String(data: mini, encoding: .utf8) else { return "[Invalid JSON]" }
        return result
    }
}

var passed = 0
var failed = 0

func check(_ name: String, _ got: String, _ expected: String) {
    if got == expected {
        passed += 1
        print("  PASS: \(name)")
    } else {
        failed += 1
        print("  FAIL: \(name)")
        print("    expected: \(expected)")
        print("    got:      \(got)")
    }
}

print("=== PasteForge Transform Tests ===\n")

// Case transforms
print("Case:")
check("uppercase", "hello world".uppercased(), "HELLO WORLD")
check("lowercase", "HELLO WORLD".lowercased(), "hello world")
check("titleCase", T.titleCase("hello world test"), "Hello World Test")
check("camelCase from spaces", T.camelCase("hello world test"), "helloWorldTest")
check("camelCase from snake", T.camelCase("hello_world_test"), "helloWorldTest")
check("camelCase from kebab", T.camelCase("hello-world-test"), "helloWorldTest")
check("snakeCase from spaces", T.snakeCase("hello world test"), "hello_world_test")
check("snakeCase from camel", T.snakeCase("helloWorldTest"), "hello_world_test")
check("kebabCase", T.kebabCase("hello world test"), "hello-world-test")
check("constantCase", T.constantCase("hello world test"), "HELLO_WORLD_TEST")

// Encode/decode
print("\nEncode/Decode:")
check("base64 encode", T.base64Encode("hello world"), "aGVsbG8gd29ybGQ=")
check("base64 decode", T.base64Decode("aGVsbG8gd29ybGQ="), "hello world")
check("base64 roundtrip", T.base64Decode(T.base64Encode("test 123!@#")), "test 123!@#")
check("url encode", T.urlEncode("hello world&foo=bar"), "hello%20world&foo=bar")
check("url decode", T.urlDecode("hello%20world%26foo%3Dbar"), "hello world&foo=bar")
check("html encode", T.htmlEncode("<div class=\"test\">&</div>"), "&lt;div class=&quot;test&quot;&gt;&amp;&lt;/div&gt;")
check("html decode", T.htmlDecode("&lt;div&gt;&amp;&lt;/div&gt;"), "<div>&</div>")
check("html roundtrip", T.htmlDecode(T.htmlEncode("<p>test & 'quote'</p>")), "<p>test & 'quote'</p>")

// Hash
print("\nHash:")
check("md5", T.md5("hello world test"), "b78f905339614b74d3345e0b5265fa35")
check("sha1", T.sha1("hello world test"), "20aede2dfe749135a7efadf0a203c74955a48a68")
check("sha256", T.sha256("hello world test"), "34fd6281487a6e36f5d4c67e6516cd0f78fdb36e647c41a86d80230161aa8951")

// Format
print("\nFormat:")
check("sortLines", T.sortLines("banana\napple\ncherry"), "apple\nbanana\ncherry")
check("uniqueLines", T.uniqueLines("a\nb\na\nc\nb"), "a\nb\nc")
check("reverseLines", T.reverseLines("a\nb\nc"), "c\nb\na")
check("trimWhitespace", T.trimWhitespace("  hello  \n  world  "), "hello\nworld")
check("addLineNumbers", T.addLineNumbers("foo\nbar"), "1  foo\n2  bar")
check("extractURLs", T.extractURLs("visit https://example.com and http://test.org please"), "https://example.com\nhttp://test.org")
check("jsonPretty valid", String(T.jsonPretty("{\"b\":2,\"a\":1}").contains("\"a\" : 1")), "true")
check("jsonPretty invalid", T.jsonPretty("not json"), "[Invalid JSON]")
check("jsonMinify", T.jsonMinify("{\n  \"a\": 1\n}"), "{\"a\":1}")

// Stats
print("\nStats:")
let testText = "hello world test"
let words = testText.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
check("charCount", "\(testText.count) characters", "16 characters")
check("wordCount", "\(words) words", "3 words")
let lines = "a\nb\nc".components(separatedBy: .newlines).count
check("lineCount", "\(lines) lines", "3 lines")
check("byteSize", "\(testText.utf8.count) B", "16 B")

print("\n=== Results: \(passed) passed, \(failed) failed ===")
if failed > 0 { exit(1) }
