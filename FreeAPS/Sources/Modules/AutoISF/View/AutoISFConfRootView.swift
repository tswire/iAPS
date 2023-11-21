import SwiftUI
import Swinject

extension AutoISFConf {
    struct RootView: BaseView {
        let resolver: Resolver
        @StateObject var state = StateModel()

        private var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }

        @State private var infoButtonPressed: InfoText?

        var body: some View {
            Form {
                ForEach(state.sections.indexed(), id: \.1.id) { sectionIndex, section in
                    Section(header: Text(section.displayName)) {
                        ForEach(section.fields.indexed(), id: \.1.id) { fieldIndex, field in
                            HStack {
                                switch field.type {
                                case .boolean:
                                    ZStack {
                                        Button("", action: {
                                            infoButtonPressed = InfoText(
                                                description: field.infoText,
                                                oref0Variable: field.displayName
                                            )
                                        })
                                        Toggle(isOn: self.$state.sections[sectionIndex].fields[fieldIndex].boolValue) {
                                            Text(field.displayName)
                                        }
                                    }
                                case .decimal:
                                    ZStack {
                                        Button("", action: {
                                            infoButtonPressed = InfoText(
                                                description: field.infoText,
                                                oref0Variable: field.displayName
                                            )
                                        })
                                        Text(field.displayName)
                                    }
                                    DecimalTextField(
                                        "0",
                                        value: self.$state.sections[sectionIndex].fields[fieldIndex].decimalValue,
                                        formatter: formatter
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .onAppear(perform: configureView)
            .navigationTitle("autoISF preferences")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarItems(
                trailing:
                Button {
                    let lang = Locale.current.languageCode ?? "en"
                    if lang == "en" {
                        UIApplication.shared.open(
                            URL(
                                string: "https://openaps.readthedocs.io/en/latest/docs/While%20You%20Wait%20For%20Gear/preferences-and-safety-settings.html"
                            )!,
                            options: [:],
                            completionHandler: nil
                        )
                    } else {
                        UIApplication.shared.open(
                            URL(
                                string: "https://openaps-readthedocs-io.translate.goog/en/latest/docs/While%20You%20Wait%20For%20Gear/preferences-and-safety-settings.html?_x_tr_sl=en&_x_tr_tl=\(lang)&_x_tr_hl=\(lang)"
                            )!,
                            options: [:],
                            completionHandler: nil
                        )
                    }
                }
                label: { Image(systemName: "questionmark.circle") }
            )
            .alert(item: $infoButtonPressed) { infoButton in
                Alert(
                    title: Text("\(infoButton.oref0Variable)"),
                    message: Text("\(infoButton.description)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
