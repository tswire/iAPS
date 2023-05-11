//
//  autoISFTableView.swift
//  FreeAPS
//
//  Created by Robert Günther on 11.05.23.
//

import Foundation
import SwiftUI
import Charts
import CoreData
import SwiftDate
import Swinject

struct autoISFTableView: View {

    @FetchRequest(
        entity: AutoISF.entity(),
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]
    )
    var fetchedAutoISF: FetchedResults<AutoISF>

    var body: some View {
        Table(fetchedAutoISF) {
            TableColumn ("Date") {entry in
                Text("\(entry.autoISF_ratio ?? 1)")
            }
        }
    }
    
}

struct autoISFTableView_Previews: PreviewProvider {
    static var previews: some View {
        autoISFTableView()
    }
}


