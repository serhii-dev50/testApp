//
//  TransactionHelper.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 26.11.2024.
//

import SwiftUI
import CoreData

class TransactionHelper {
    
    // Adds a new transaction to the context and updates the balance.
    static func addTransaction(amount: Double, category: String, type: String, viewContext: NSManagedObjectContext, balances: FetchedResults<Balance>) {
        let transaction = Transaction(context: viewContext)
        transaction.amount = amount
        transaction.category = category
        transaction.type = type
        transaction.date = Date()

        if let firstBalance = balances.first {
            firstBalance.total += amount
        } else {
            let newBalance = Balance(context: viewContext)
            newBalance.total = amount
        }

        saveContext(viewContext: viewContext)
    }

    // Deletes a specific transaction and adjusts the balance accordingly
    static func deleteTransaction(_ transaction: Transaction, viewContext: NSManagedObjectContext, balances: FetchedResults<Balance>) {
        if let firstBalance = balances.first {
            firstBalance.total -= transaction.amount
        }
        viewContext.delete(transaction)
        saveContext(viewContext: viewContext)
    }

    // Deletes all data in both the `Balance` and `Transaction` entities
    static func deleteAllData(viewContext: NSManagedObjectContext, balances: FetchedResults<Balance>, transactions: FetchedResults<Transaction>, refreshData: Binding<Bool>) {
        let fetchRequestBalance: NSFetchRequest<NSFetchRequestResult> = Balance.fetchRequest()
        let deleteBalanceRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestBalance)
        
        let fetchRequestTransaction: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteTransactionRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestTransaction)

        do {
            try viewContext.execute(deleteBalanceRequest)
            try viewContext.execute(deleteTransactionRequest)
            
            viewContext.processPendingChanges()
            let newBalance = Balance(context: viewContext)
            newBalance.total = 0.0
            
            try viewContext.save()
            
            refreshData.wrappedValue.toggle()

        } catch {
            print("Ошибка при удалении всех данных: \(error.localizedDescription)")
        }
    }
    
    // Reloads fetched data for balances and transactions
    static func reloadFetchedData(balances: FetchedResults<Balance>, transactions: FetchedResults<Transaction>) {
        balances.nsPredicate = NSPredicate(value: true)
        balances.nsPredicate = nil

        transactions.nsPredicate = NSPredicate(value: true)
        transactions.nsPredicate = nil
    }
    
    // Prepares for editing a transaction
    static func startEditing(transaction: Transaction) -> (Transaction?, String) {
        let newAmount = "\(transaction.amount)"
        return (transaction, newAmount)
    }

    // Saves the edited transaction and updates the balance
    static func saveEditedTransaction(_ transaction: Transaction, newAmount: String, viewContext: NSManagedObjectContext, balances: FetchedResults<Balance>) {
        if let updatedAmount = Double(newAmount) {
            let difference = updatedAmount - transaction.amount
            transaction.amount = updatedAmount

            if let firstBalance = balances.first {
                firstBalance.total += difference
            }
            saveContext(viewContext: viewContext)
        }
    }

    // Saves changes in the Core Data context
    private static func saveContext(viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
