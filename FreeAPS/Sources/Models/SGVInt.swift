import Foundation

enum SGVInt: String, JSON, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case sgv1min
    case sgv3min
    case sgv5min

    var displayName: String {
        switch self {
        case .sgv1min:
            return NSLocalizedString("1 min", comment: "")
        case .sgv3min:
            return NSLocalizedString("3 mins", comment: "")
        case .sgv5min:
            return NSLocalizedString("5 mins", comment: "")
        }
    }
}
