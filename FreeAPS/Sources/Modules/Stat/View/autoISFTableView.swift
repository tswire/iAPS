import Charts
import CoreData
import Foundation
import SwiftDate
import SwiftUI
import Swinject

extension Stat {
    struct autoISFTableView: BaseView {
        @Binding var isPresented: Bool // Add this to control the presentation
        @Environment(\.managedObjectContext) private var viewContext

        @State private var selectedEndTime = Date()
        @State private var selectedTimeIntervalIndex = 1 // Default to 2 hours
        let timeIntervalOptions = [1, 2, 4, 8] // Hours

        @State private var autoISFResults: [AutoISF] = [] // Holds the fetched results
        @Environment(\.horizontalSizeClass) var sizeClass
        let resolver: Resolver
        @StateObject var state = StateModel()
        @Environment(\.colorScheme) var colorScheme

//        @FetchRequest(
//            entity: AutoISF.entity(),
//            sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
//            predicate: NSPredicate(
//                format: "timestamp > %@",
//                Date().addingTimeInterval(-3.hours.timeInterval) as NSDate
//            )
//        ) var fetchedAutoISF: FetchedResults<AutoISF>

        private func fetchAutoISF() {
            let endTime = selectedEndTime
            // Calculate start time based on the selected interval
            let intervalHours = timeIntervalOptions[selectedTimeIntervalIndex]
            let startTime = Calendar.current.date(byAdding: .hour, value: -intervalHours, to: endTime)!

            let request: NSFetchRequest<AutoISF> = AutoISF.fetchRequest()
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", argumentArray: [startTime, endTime])
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

            do {
                autoISFResults = try viewContext.fetch(request)
            } catch {
                print("Fetch error: \(error.localizedDescription)")
            }
        }

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

        private let itemFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            return formatter
        }()

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
                            HStack {
                                DatePicker(
                                    "",
                                    selection: $selectedEndTime,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .onChange(of: selectedEndTime) { _ in
                                    fetchAutoISF()
                                }
                                Spacer()
                                Picker("", selection: $selectedTimeIntervalIndex) {
                                    ForEach(0 ..< timeIntervalOptions.count, id: \.self) { index in
                                        Text("\(self.timeIntervalOptions[index]) hours").tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: selectedTimeIntervalIndex) { _ in
                                    fetchAutoISF()
                                }
                            }
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
                .onAppear(perform: fetchAutoISF)
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
                List {
                    ForEach(autoISFResults, id: \.self) { entry in
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
                }
            }
        }
    }
}
