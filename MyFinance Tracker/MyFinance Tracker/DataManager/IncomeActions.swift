//
//  IncomeActions.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 26.11.2024.
//

import Foundation
import CoreData

// Helper function to filter and format the amount input
func filterAmountInput(_ newValue: String) -> String {
    let filtered = newValue.filter { "0123456789.".contains($0) }
    let pointCount = filtered.filter { $0 == "." }.count
    if pointCount <= 1 {
        return filtered
    } else {
        let firstPointIndex = filtered.firstIndex(of: ".") ?? filtered.endIndex
        return String(filtered.prefix(upTo: firstPointIndex)) + "." + filtered.suffix(from: firstPointIndex).filter { $0.isNumber }
    }
}

// Helper function to add income and update the balance
func addIncome(amount: Double, selectedDate: Date, viewContext: NSManagedObjectContext) {
    let transaction = Transaction(context: viewContext)
    transaction.amount = amount
    transaction.type = "Income"
    transaction.date = selectedDate
    
    if let firstBalance = try? viewContext.fetch(Balance.fetchRequest()).first {
        firstBalance.total += amount
    } else {
        let newBalance = Balance(context: viewContext)
        newBalance.total = amount
    }
    
    saveContext(viewContext: viewContext)
}

// Helper function to save the context
func saveContext(viewContext: NSManagedObjectContext) {
    do {
        try viewContext.save()
    } catch {
        print("Failed to save context: \(error.localizedDescription)")
    }
}
