import AppIntents
import Foundation

@available(iOS 16.0, *) struct AppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ApplyTempPresetIntent(),
            phrases: [
                "Activate \(.applicationName) TemTarget Preset",
                "Activates an available \(.applicationName) temporary target preset"
            ]
        )
        AppShortcut(
            intent: CreateAndApplyTempTarget(),
            phrases: [
                "New \(.applicationName) TempTarget",
                "Creates and applies a newly configured \(.applicationName) temporary target"
            ]
        )
        AppShortcut(
            intent: CancelTempPresetIntent(),
            phrases: [
                "Cancel \(.applicationName) TempTarget",
                "Cancels an active \(.applicationName) TempTarget"
            ]
        )
        AppShortcut(
            intent: ListStateIntent(),
            phrases: [
                "List \(.applicationName) state",
                "Lists different states of \(.applicationName)"
            ]
        )
        AppShortcut(
            intent: AddCarbPresentIntent(),
            phrases: [
                "\(.applicationName) Carbs",
                "Adds carbs to \(.applicationName)"
            ]
        )
        AppShortcut(
            intent: ApplyOverrideIntent(),
            phrases: [
                "Activate \(.applicationName) Override Preset",
                "Activates an available \(.applicationName) Override Preset"
            ]
        )
        AppShortcut(
            intent: CancelOverrideIntent(),
            phrases: [
                "Cancel \(.applicationName) Overide",
                "Cancels an active \(.applicationName) override"
            ]
        )
        AppShortcut(
            intent: BolusIntent(),
            phrases: [
                "\(.applicationName) Bolus",
                "Enacts a new \(.applicationName) bolus"
            ]
        )
    }
}
