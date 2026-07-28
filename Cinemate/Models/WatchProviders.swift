import Foundation

struct WatchProvidersResponse: Codable {
    let results: [String: CountryProviders]
}

struct CountryProviders: Codable {
    let link: String?
    let flatrate: [WatchProvider]?
}

struct WatchProvider: Codable, Hashable, Identifiable {
    var id: Int { providerId }
    let providerId: Int
    let providerName: String
    let logoPath: String?
}
