import Charts
import CoreData
import Foundation
import SwiftDate
import SwiftUI
import Swinject

extension Stat {
    struct autoISFTableView: BaseView {
        @Binding var isPresented: Bool // Add this to control the presentation
        @Environment(\.horizontalSizeClass) var sizeClass
        let resolver: Resolver
        @StateObject var state = StateModel()
        @Environment(\.colorScheme) var colorScheme

        @FetchRequest(
            entity: AutoISF.entity(),
            sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
            predicate: NSPredicate(
                format: "timestamp > %@",
                Date().addingTimeInterval(-3.hours.timeInterval) as NSDate
            )
        ) var fetchedAutoISF: FetchedResults<AutoISF>

        var slots: CGFloat = 12
        var slotwidth: CGFloat = 1

        private var color: LinearGradient {
            colorScheme == .dark ? LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.011, green: 0.058, blue: 0.109),
                    Color(red: 0.03921568627, green: 0.1333333333, blue: 0.2156862745)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
                :
                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
        }

        @ViewBuilder func historyISF() -> some View {
            autoISFview
        }

        var body: some View {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        VStack(alignment: .center) {
                            HStack {
                                Text("autoISF Calculations").font(.headline).bold().padding(10)
                                Spacer()
                                Button(action: {
                                    self.isPresented = false
                                }) {
                                    Text("Close")
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }.padding(5)
                            }
                            Spacer()
                            HStack(alignment: .lastTextBaseline) {
                                Spacer()
                                Text("ISF factors").foregroundColor(.uam)
                                    .frame(width: 6 * slotwidth / slots * geometry.size.width, alignment: .center)
                                Text("Insulin").foregroundColor(.insulin)
                                    .frame(width: 4 * slotwidth / slots * geometry.size.width, alignment: .center)
                            }
                            if sizeClass == .compact {
                                HStack {
                                    Group {
                                        Text("Time")
                                        Spacer()
                                        Text("BG").foregroundColor(.loopGreen)
                                    }
                                    Spacer()
                                    Group {
                                        Text("final").bold()
                                        Spacer()
                                        Text("acce")
                                        Spacer()
                                        Text("bg")
                                        Spacer()
                                        Text("pp")
                                        Spacer()
                                        Text("dura") }
                                        .foregroundColor(.uam)
                                    Spacer()
                                    Group {
                                        Text("req.")
                                        Spacer()
                                        Text("SMB")
                                        Spacer()
                                        Text("TBR") }
                                        .foregroundColor(.insulin)
                                }
                                .frame(width: 0.95 * geometry.size.width)
                                Divider()
                            }
                            historyISF()
                        }
                        .font(.caption)
                    }
                }
                .onAppear(perform: configureView)
                .navigationBarTitle("History")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Close", action: state.hideModal))
                .scrollContentBackground(.hidden).background(color)
            }
        }

        var timeFormatter: DateFormatter = {
            let formatter = DateFormatter()

            formatter.dateStyle = .none
            formatter.timeStyle = .short

            return formatter
        }()

        var autoISFview: some View {
            GeometryReader { geometry in
                Table(fetchedAutoISF) {
                    TableColumn("BG") { entry in
                        HStack(spacing: 2) {
                            Text(timeFormatter.string(from: entry.timestamp ?? Date()))
                                .frame(width: 1.3 / slots * geometry.size.width, alignment: .leading)

                            if sizeClass == .compact {
                                Text("\(entry.bg ?? 0)")
                                    .foregroundColor(.loopGreen)
                                    .frame(width: 1.1 / slots * geometry.size.width, alignment: .center)
                                Group {
                                    Text("\(entry.autoISF_ratio ?? 1)")
                                    Text("\(entry.acce_ratio ?? 1)")
                                    Text("\(entry.bg_ratio ?? 1)")
                                    Text("\(entry.pp_ratio ?? 1)")
                                    Text("\(entry.dura_ratio ?? 1)") }
                                    .frame(width: slotwidth / slots * geometry.size.width, alignment: .trailing)
                                    .foregroundColor(.uam)
                                Group {
                                    Text("\(entry.insulin_req ?? 0)")
                                        .frame(width: 1.5 * slotwidth / slots * geometry.size.width, alignment: .trailing)
                                    Text("\(entry.smb ?? 0)")
                                    Text("\(entry.tbr ?? 0)") }
                                    .frame(width: slotwidth / slots * geometry.size.width, alignment: .trailing)
                                    .foregroundColor(.insulin)
                            }
                        }
                    }
                    TableColumn("BG") { entry in Text("\(entry.bg ?? 0)") }
                    TableColumn("final") { entry in Text("\(entry.autoISF_ratio ?? 1)") }
                    TableColumn("acce") { entry in Text("\(entry.acce_ratio ?? 1)") }
                    TableColumn("bg") { entry in Text("\(entry.bg_ratio ?? 1)") }
                    TableColumn("pp") { entry in Text("\(entry.pp_ratio ?? 1)") }
                    TableColumn("dura") { entry in Text("\(entry.dura_ratio ?? 1)") }
                    TableColumn("Ins.req.") { entry in Text("\(entry.insulin_req ?? 0)") }
                    TableColumn("SMB") { entry in Text("\(entry.smb ?? 0)") }
                    TableColumn("TBR") { entry in Text("\(entry.tbr ?? 0)") }
                }
            }
        }
    }
}
