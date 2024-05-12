import SwiftUI

extension AutoISFConf {
    final class StateModel: BaseStateModel<Provider>, PreferencesSettable {
        private(set) var preferences = Preferences()
        @Injected() var settings: SettingsManager!
        @Injected() var storage: FileStorage!

        @Published var unit: GlucoseUnits = .mmolL
        @Published var sections: [FieldSection] = []
        @Published var autoisf: Bool = false

        override func subscribe() {
            unit = settingsManager.settings.units
            preferences = provider.preferences
            autoisf = settings.preferences.autoisf

            // MARK: - autoISF fields

            let autoisfConfig = [
                Field(
                    displayName: NSLocalizedString("Enable Autosens", comment: "Enable Autosens"),
                    type: .boolean(keypath: \.enableAutosens),
                    infoText: NSLocalizedString(
                        "Switch Autosens on/off",
                        comment: "Autosens"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "Temp Targets toggle SMB for autoISF",
                    type: .boolean(keypath: \.enableSMBEvenOnOddOff),
                    infoText: NSLocalizedString(
                        "Defaults to false. If true, autoISF will block SMB's when odd TempTargets are used (lower boundary) and enforce SMB, when even TempTargets are used. autoISF is still active and adjusting ISF's. In case of exercise_mode or high_temptarget_raises_sensitivity being true and any High TT being active, it adjusts the oref calculataed ISF, not profile ISF. Only appliccable if autoISF is enabled.",
                        comment: "Odd TT disable SMB"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "Odd Profile Target disables SMB for autoISF",
                    type: .boolean(keypath: \.enableSMBEvenOnOddOffalways),
                    infoText: NSLocalizedString(
                        "Defaults to false. If true, autoISF will block SMB's when odd ProfileTargets are used (lower boundary = upper boundary)",
                        comment: "Odd Target disable SMB"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "Excercise toggles all autoISF adjustments off",
                    type: .boolean(keypath: \.autoISFoffSport),
                    infoText: NSLocalizedString(
                        "Defaults to true. When true, switches off complete autoISF during high TT in excercise mode.",
                        comment: "Switch off autoISF with exercise"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "Exercise Mode",
                    type: .boolean(keypath: \.exerciseMode),
                    infoText: NSLocalizedString(
                        "Defaults to false. When true, > 100 mg/dL high temp target adjusts sensitivityRatio for exercise mode. Synonym for high_temptarget_raises_sensitivity",
                        comment: "Exercise Mode"
                    ),
                    settable: self
                ),
                Field(
                    displayName: NSLocalizedString("Half Basal Exercise Target", comment: "Half Basal Exercise Target") +
                        " (mg/dL)",
                    type: .decimal(keypath: \.halfBasalExerciseTarget),
                    infoText: NSLocalizedString(
                        "Set to a number in mg/dl, e.g. 160, which means when TempTarget (TT) is 160 mg/dL and exercise mode = true, it will run 50% basal at this TT level (if high TT at 120 = 75%; 140 = 60%). This can be adjusted, to give you more control over your exercise modes.",
                        comment: "Half Basal Exercise Target"
                    ),
                    settable: self
                )
            ]

            let xpmToogles = [
                Field(
                    displayName: NSLocalizedString("Max IOB", comment: "Max IOB"),
                    type: .decimal(keypath: \.maxIOB),
                    infoText: NSLocalizedString(
                        "Max IOB is the maximum amount of insulin on board from all sources – both basal (or SMB correction) and bolus insulin – that your loop is allowed to accumulate to treat higher-than-target BG. Unlike the other two OpenAPS safety settings (max_daily_safety_multiplier and current_basal_safety_multiplier), max_iob is set as a fixed number of units of insulin. As of now manual boluses are NOT limited by this setting. \n\n To test your basal rates during nighttime, you can modify the Max IOB setting to zero while in Closed Loop. This will enable low glucose suspend mode while testing your basal rates settings\n\n(Tip from https://www.loopandlearn.org/freeaps-x/#open-loop).",
                        comment: "Max IOB"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "autoISF IOB Threshold Percent",
                    type: .decimal(keypath: \.iobThresholdPercent),
                    infoText: NSLocalizedString(
                        "Default value: 100%. This is the share of maxIOB above which autoISF will disable SMB. Relative level of maxIOB above which SMBs are disabled. With 100% this feature is effectively disabled.",
                        comment: "autoISF IOB threshold percent"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "autoISF Max",
                    type: .decimal(keypath: \.autoISFmax),
                    infoText: NSLocalizedString(
                        "Multiplier cap on how high the autoISF ratio can be and therefore how low it can adjust ISF.",
                        comment: "autoISF Max"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "autoISF Min",
                    type: .decimal(keypath: \.autoISFmin),
                    infoText: NSLocalizedString(
                        "This is a multiplier cap for autoISF to set a limit on how low the autoISF ratio can be, which in turn determines how high it can adjust ISF.",
                        comment: "autoISF Min"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "Enable BG acceleration",
                    type: .boolean(keypath: \.enableBGacceleration),
                    infoText: NSLocalizedString(
                        "Enables the BG acceleration adaptions, adjusting ISF for accelerating/decelerating blood glucose.",
                        comment: "Enable BG accel in autoISF"
                    ),
                    settable: self
                )
            ]
            let xpmDuraISF = [
                Field(
                    displayName: "Enable DuraISF effect with COB",
                    type: .boolean(keypath: \.enableautoISFwithCOB),
                    infoText: NSLocalizedString(
                        "Enable DuraISF even if COB is present not just for UAM.",
                        comment: "Enable autoISF with COB"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "DuraISF weight",
                    type: .decimal(keypath: \.autoISFhourlyChange),
                    infoText: NSLocalizedString(
                        "Rate at which ISF is reduced per hour assuming BG leveel remains at double target for that time. When value = 1.0, ISF is reduced to 50% after 1 hour of BG level at 2x target.",
                        comment: "autoISF HourlyMaxChange"
                    ),
                    settable: self
                )
            ]

            let xpmBGISF = [
                Field(
                    displayName: "ISF weight for lower BG's",
                    type: .decimal(keypath: \.lowerISFrangeWeight),
                    infoText: NSLocalizedString(
                        "Default value: 0.0 This is the weight applied to the polygon which adapts ISF if glucose is below target. With 0.0 the effect is effectively disabled.",
                        comment: "ISF low BG weight"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "ISF weight for higher BG's",
                    type: .decimal(keypath: \.higherISFrangeWeight),
                    infoText: NSLocalizedString(
                        "Default value: 0.0 This is the weight applied to the polygon which adapts ISF if glucose is above target. With 0.0 the effect is effectively disabled.",
                        comment: "ISF high BG weight"
                    ),
                    settable: self
                )
            ]
            let xpmDeltaISF = [
                Field(
                    displayName: "ISF weight for higher BG deltas",
                    type: .decimal(keypath: \.deltaISFrangeWeight),
                    infoText: NSLocalizedString(
                        "Default value: 0.0 This is the weight applied to the polygon which adapts ISF higher deltas. With 0.0 the effect is effectively disabled.",
                        comment: "ISF higher delta BG weight"
                    ),
                    settable: self
                )
            ]

            let xpmAcceISF = [
                Field(
                    displayName: "ISF weight while BG accelerates",
                    type: .decimal(keypath: \.bgAccelISFweight),
                    infoText: NSLocalizedString(
                        "Default value: 0. This is the weight applied while glucose accelerates and which strengthens ISF. With 0 this contribution is effectively disabled. 0.02 is a safe starting point, from which to move up. Typical settings are around 0.15!",
                        comment: "ISF acceleration weight"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "ISF weight while BG decelerates",
                    type: .decimal(keypath: \.bgBrakeISFweight),
                    infoText: NSLocalizedString(
                        "Default value: 0. This is the weight applied while glucose decelerates and which weakens ISF. With 0 this contribution is effectively disabled. 0.1 might be a good starting point.",
                        comment: "ISF decceleration weight"
                    ),
                    settable: self
                )
            ]

            let xpmPostPrandial = [
                Field(
                    displayName: "Enable always postprandial ISF adaption",
                    type: .boolean(keypath: \.postMealISFalways),
                    infoText: NSLocalizedString(
                        "Enable the postprandial ISF adaptation all the time regardless of when the last meal was taken.",
                        comment: "Enable postprandial ISF always"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "Duration ISF postprandial adaption",
                    type: .decimal(keypath: \.postMealISFduration),
                    infoText: NSLocalizedString(
                        "Default value: 3 This is the duration in hours how long after a meal the effect will be active. Oref will delete carb timing after 10 hours latest no matter what you enter.",
                        comment: "ISF postprandial change duration"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "ISF weight for postprandial BG rise",
                    type: .decimal(keypath: \.postMealISFweight),
                    infoText: NSLocalizedString(
                        "Default value: 0 This is the weight applied to the linear slope while glucose rises and  which adapts ISF. With 0 this contribution is effectively disabled. Start with 0.01 - it hardly goes beyond 0.05!",
                        comment: "ISF postprandial weight"
                    ),
                    settable: self
                )
            ]

            let xpmSMB = [
                Field(
                    displayName: "SMB DeliveryRatio",
                    type: .decimal(keypath: \.smbDeliveryRatio),
                    infoText: NSLocalizedString(
                        "Default value: 0.5 This is another key OpenAPS safety cap, and specifies what share of the total insulin required can be delivered as SMB. This is to prevent people from getting into dangerous territory by setting SMB requests from the caregivers phone at the same time. Increase this experimental value slowly and with caution. YOu can use that with autoISF to increase the SMB DR immediatly indpendant of BG if you use an Eating Soon TT (even and below 100). This SMB DR will than be used, independantly of the 3 following options, that normally superceed his setting.",
                        comment: "SMB DeliveryRatio"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "SMB DeliveryRatio BG Minimum",
                    type: .decimal(keypath: \.smbDeliveryRatioMin),
                    infoText: NSLocalizedString(
                        "Default value: 0.5 This is the lower end of a linearly increasing SMB Delivery Ratio rather than the fix value above in SMB DeliveryRatio.",
                        comment: "SMB DeliveryRatio Minimum"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "SMB DeliveryRatio BG Maximum",
                    type: .decimal(keypath: \.smbDeliveryRatioMax),
                    infoText: NSLocalizedString(
                        "Default value: 0.5 This is the higher end of a linearly increasing SMB Delivery Ratio rather than the fix value above in SMB DeliveryRatio.",
                        comment: "SMB DeliveryRatio Minimum"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "SMB DeliveryRatio BG Range",
                    type: .decimal(keypath: \.smbDeliveryRatioBGrange),
                    infoText: NSLocalizedString(
                        "Default value: 0, Sensible is bteween 40 and 120. The linearly increasing SMB delivery ratio is mapped to the glucose range [target_bg, target_bg+bg_range]. At target_bg the SMB ratio is smb_delivery_ratio_min, at target_bg+bg_range it is smb_delivery_ratio_max. With 0 the linearly increasing SMB ratio is disabled and the fix smb_delivery_ratio is used.",
                        comment: "SMB DeliveryRatio BG Range"
                    ),
                    settable: self
                ),
                Field(
                    displayName: "SMB Max RangeExtension",
                    type: .decimal(keypath: \.smbMaxRangeExtension),
                    infoText: NSLocalizedString(
                        "Default value: 1. This is another key OpenAPS safety cap, and specifies by what factor you can exceed the regular 120 maxSMB/maxUAM minutes. Increase this experimental value slowly and with caution. Available only when autoISF is enabled.",
                        comment: "SMB Max RangeExtension"
                    ),
                    settable: self
                )
            ]

            sections = [
                FieldSection(
                    displayName: NSLocalizedString("Target & Exercise Control", comment: "AutoISF control via Targets"),
                    fields: autoisfConfig
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "Toggles & General Settings",
                        comment: "Switch on/off experimental stuff"
                    ),
                    fields: xpmToogles
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "Acce-ISF Settings",
                        comment: "Experimental settings for acceleration based autoISF 2.2"
                    ),
                    fields: xpmAcceISF
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "PP-ISF Settings",
                        comment: "Experimental settings for postprandial based autoISF 2.2"
                    ),
                    fields: xpmPostPrandial
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "Delta-ISF Settings",
                        comment: "Experimental settings for BG delta based autoISF2.1"
                    ),
                    fields: xpmDeltaISF
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "BG-ISF Settings",
                        comment: "Experimental settings for BG level based autoISF2.1"
                    ),
                    fields: xpmBGISF
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "Dura-ISF Settings",
                        comment: "Experimental settings for high BG plateau based autoISF2.0"
                    ),
                    fields: xpmDuraISF
                ),
                FieldSection(
                    displayName: NSLocalizedString(
                        "SMB Delivery Ratio Settings",
                        comment: "Experimental settings for SMB increases autoISF 2.0"
                    ),
                    fields: xpmSMB
                )
            ]
        }

        var unChanged: Bool {
            preferences.autoisf == autoisf
        }

        func convertBack(_ glucose: Decimal) -> Decimal {
            if unit == .mmolL {
                return glucose.asMgdL
            }
            return glucose
        }

        func save() {
            provider.savePreferences(preferences)
        }

        func set<T>(_ keypath: WritableKeyPath<Preferences, T>, value: T) {
            preferences[keyPath: keypath] = value
            save()
        }

        func get<T>(_ keypath: WritableKeyPath<Preferences, T>) -> T {
            preferences[keyPath: keypath]
        }

        func saveIfChanged() {
            if !unChanged {
                var newSettings = storage.retrieve(OpenAPS.Settings.preferences, as: Preferences.self) ?? Preferences()
                newSettings.autoisf = autoisf
                newSettings.timestamp = Date()
                storage.save(newSettings, as: OpenAPS.Settings.preferences)
            }
        }
    }
}
