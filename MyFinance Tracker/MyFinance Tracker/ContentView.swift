//
//  ContentView.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 25.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        ZStack {
          MainList()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
