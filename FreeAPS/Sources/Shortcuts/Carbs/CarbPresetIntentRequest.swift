import CoreData
import Foundation

@available(iOS 16.0,*) final class CarbPresetIntentRequest: BaseIntentsRequest {
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }

    var presetCarbsList: [carbPresetResult] {
        var carbsList = [Presets]()
        let requestcarbsList = Presets.fetchRequest() as NSFetchRequest<Presets>
        try? carbsList = coredataContext.fetch(requestcarbsList)
        return carbsList.compactMap {
            carbPresetResult(
                id: $0.objectID.hash,
                name: $0.dish ?? "-",
                carbs: ($0.carbs ?? 0.0) as! Double,
                fat: ($0.fat ?? 0.0) as! Double,
                protein: ($0.protein ?? 0.0) as! Double
            )
        }
    }

    func addCarbs(
        _ quantityCarbs: Double,
        _ quantityFat: Double,
        _ quantityProtein: Double,
        _ dateAdded: Date
    ) throws -> LocalizedStringResource {
        guard quantityCarbs >= 0.0 || quantityFat >= 0.0 || quantityProtein >= 0.0 else {
            return LocalizedStringResource("no adding carbs", table: "ShortcutsDetail")
        }

        let carbs = min(Decimal(quantityCarbs), settingsManager.settings.maxCarbs)

        carbsStorage.storeCarbs(
            [CarbsEntry(
                id: UUID().uuidString,
                createdAt: dateAdded,
                actualDate: dateAdded,
                carbs: carbs,
                fat: Decimal(quantityFat),
                protein: Decimal(quantityProtein),
                note: "add with shortcuts",
                enteredBy: CarbsEntry.manual,
                isFPU: false, fpuID: nil
            )]
        )
        let dateName = dateAdded.formatted()
        let carbsFormatted = numberFormatter.string(from: carbs as NSNumber) ?? "0"
        let fatsFormatted = numberFormatter.string(from: quantityFat as NSNumber) ?? "0"
        let proteinsFormatted = numberFormatter.string(from: quantityProtein as NSNumber) ?? "0"
        return LocalizedStringResource(
            " \(carbsFormatted) g carbs and \(fatsFormatted) g fats and \(proteinsFormatted) g proteins added at \(dateName)",
            table: "ShortcutsDetail"
        )
    }

    func listPresetCarbs() throws -> [carbPresetResult] {
        presetCarbsList
    }

    func listPresetCarbs(_ ids: [Int]) throws -> [carbPresetResult] {
        presetCarbsList.filter {
            ids.contains($0.id)
        }
    }

    func getCarbsPresetInfo(presetId: Int) throws -> carbPresetResult? {
        presetCarbsList.first {
            $0.id == presetId
        }
    }
}
