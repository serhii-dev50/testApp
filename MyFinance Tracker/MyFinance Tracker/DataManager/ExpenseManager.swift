//
//  ExpenseManager.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 26.11.2024.
//

import SwiftUI
import CoreData

    // Class to manage expenses and categories in Core Data
class ExpenseManager {
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    // Method to save an expense transaction to Core Data
    func saveExpense(amount: String, selectedCategory: String, isPresented: Binding<Bool>) {
        if let amountValue = Double(amount) {
            let transaction = Transaction(context: viewContext)
            transaction.amount = -amountValue
            transaction.category = selectedCategory
            transaction.date = Date()
            
            if let firstBalance = try? viewContext.fetch(Balance.fetchRequest()).first {
                firstBalance.total -= amountValue
            } else {
                let newBalance = Balance(context: viewContext)
                newBalance.total = -amountValue
            }
            do {
                try viewContext.save()
                isPresented.wrappedValue = false
            } catch {
                print("Failed to save expense: \(error.localizedDescription)")
            }
        }
    }
    
    // Method to add a new category to the list of categories
    func addCategory(newCategory: String, categories: FetchedResults<Category>, viewContext: NSManagedObjectContext) {
        let trimmedCategory = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCategory.isEmpty, !categories.contains(where: { $0.name == trimmedCategory }) else { return }
        
        let category = Category(context: viewContext)
        category.name = trimmedCategory
        do {
            try viewContext.save()
        } catch {
            print("Failed to save category: \(error.localizedDescription)")
        }
    }
    
    // Method to remove an existing category from Core Data
    func removeCategory(named categoryName: String, categories: FetchedResults<Category>, viewContext: NSManagedObjectContext) {
        if let categoryToRemove = categories.first(where: { $0.name == categoryName }) {
            viewContext.delete(categoryToRemove)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete category: \(error.localizedDescription)")
            }
        }
    }
}
