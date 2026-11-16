//
//  qct_iosApp.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import SwiftUI
import CoreData

@main
struct qct_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
