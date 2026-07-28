import Foundation

enum NewsService {
    static let feeds: [(name: String, url: String)] = [
        ("/Film", "https://www.slashfilm.com/feed/"),
        ("Collider", "https://collider.com/feed/"),
        ("IndieWire", "https://www.indiewire.com/feed/"),
        ("ScreenRant", "https://screenrant.com/feed/")
    ]

    static func loadNews() async -> [NewsItem] {
        await withTaskGroup(of: [NewsItem].self) { group in
            for feed in feeds {
                let name = feed.name
                let urlString = feed.url
                group.addTask { await fetchFeed(name: name, urlString: urlString) }
            }
            var all: [NewsItem] = []
            for await items in group { all.append(contentsOf: items) }
            return all.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        }
    }

    private static func fetchFeed(name: String, urlString: String) async -> [NewsItem] {
        guard let url = URL(string: urlString) else { return [] }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (compatible; CinemaApp/1.0)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return RSSParser(source: name).parse(data)
        } catch {
            return []
        }
    }
}

final class RSSParser: NSObject, XMLParserDelegate {
    private let source: String
    private var items: [NewsItem] = []

    private var currentElement = ""
    private var insideItem = false
    private var title = ""
    private var link = ""
    private var pubDate = ""
    private var image = ""
    private var contentHTML = ""

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return f
    }()

    init(source: String) {
        self.source = source
    }

    func parse(_ data: Data) -> [NewsItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName

        if elementName == "item" {
            insideItem = true
            title = ""; link = ""; pubDate = ""; image = ""; contentHTML = ""
            return
        }

        guard insideItem, image.isEmpty else { return }

        if elementName == "media:content" || elementName == "media:thumbnail" {
            if let url = attributeDict["url"] { image = url }
        } else if elementName == "enclosure",
                  let url = attributeDict["url"],
                  attributeDict["type"]?.hasPrefix("image") == true {
            image = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        switch currentElement {
        case "title": title += string
        case "link": link += string
        case "pubDate": pubDate += string
        case "content:encoded", "description": contentHTML += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            insideItem = false

            let cleanTitle = decodeEntities(title.trimmingCharacters(in: .whitespacesAndNewlines))
            let cleanLink = link.trimmingCharacters(in: .whitespacesAndNewlines)

            if image.isEmpty { image = firstImageURL(in: contentHTML) ?? "" }

            if !cleanTitle.isEmpty, let url = URL(string: cleanLink) {
                let date = RSSParser.dateFormatter.date(from: pubDate.trimmingCharacters(in: .whitespacesAndNewlines))
                let imageURL = URL(string: image.trimmingCharacters(in: .whitespacesAndNewlines))
                items.append(NewsItem(title: cleanTitle, link: url, source: source, date: date, imageURL: imageURL))
            }
        }
        currentElement = ""
    }

    private func firstImageURL(in html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "<img[^>]+src=[\"']([^\"']+)[\"']", options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              match.numberOfRanges > 1,
              let captured = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[captured])
    }

    private func decodeEntities(_ string: String) -> String {
        var result = string
        let map = [
            "&amp;": "&", "&#38;": "&", "&quot;": "\"", "&#34;": "\"",
            "&apos;": "'", "&#39;": "'", "&#8217;": "’", "&#8216;": "‘",
            "&#8220;": "“", "&#8221;": "”", "&lt;": "<", "&gt;": ">",
            "&#8211;": "–", "&#8212;": "—", "&hellip;": "…", "&#8230;": "…"
        ]
        for (key, value) in map {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }
}
