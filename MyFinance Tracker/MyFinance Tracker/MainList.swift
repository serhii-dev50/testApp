//
//  MainList.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 25.11.2024.
//
import SwiftUI
import CoreData

struct MainList: View {
    @State private var isPresentingAddIncome: Bool = false
    @FetchRequest(entity: Balance.entity(), sortDescriptors: []) var balances: FetchedResults<Balance>
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]) var transactions: FetchedResults<Transaction>
    @Environment(\.managedObjectContext) private var viewContext
    @State private var editingTransaction: Transaction?
    @State private var newAmount: String = ""
    @State private var isEditing: Bool = false
    @State private var isPresentingAddExpense: Bool = false
    @State private var isPresentingStatistics: Bool = false
    @State private var refreshData: Bool = false
  
    
    private var totalBalance: Double {
        return balances.first?.total ?? 0.0
    }
    @State private var selectedDate: Date = Date()
    
    // Filter transactions to only include those on the selected date
    private var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            guard let transactionDate = transaction.date else { return false }
            
            let calendar = Calendar.current
            return calendar.isDate(transactionDate, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    
                    // Header with buttons
                    HStack {
                        Button(action: {
                            TransactionHelper.deleteAllData(viewContext: viewContext, balances: balances, transactions: transactions, refreshData: $refreshData)
                        }){
                            ZStack {
                                Circle()
                                    .frame(width: 33, height: 33)
                                    .foregroundColor(.red.opacity(0.4))
                                Image(systemName: "trash")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
                        Text("Finance Tracker")
                        Spacer()
                        Button(action: {  isPresentingStatistics = true }){
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    // Total balance display
                    Text("Total Balance")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                    
                    Text("\(totalBalance, specifier: "%.2f") $")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(totalBalance >= 0 ? .green : .red)
                    
                    Spacer()
                    
                    // Buttons for adding income and expense
                    HStack(spacing: 10) {
                        Button(action: {
                            isPresentingAddIncome = true
                        }) {
                            Text("Add Income")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $isPresentingStatistics) {
                            StatisticsView(transactions: transactions, isPresented: $isPresentingStatistics)
                        }
                        
                        Button(action: {
                            isPresentingAddIncome = false
                            isPresentingAddExpense = true
                            
                        }) {
                            Text("Add Expense")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $isPresentingAddExpense) {
                        AddExpenseSheet(isPresented: $isPresentingAddExpense, viewContext: viewContext)
                    }
                    .sheet(isPresented: $isPresentingAddIncome) {
                        AddIncomeSheet(isPresented: $isPresentingAddIncome, refreshData: $refreshData)
                    }
                    
                    // Transaction section header with a date picker
                    HStack {
                        Text("Transactions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(.green)
                    }
                    .padding(.horizontal, 15)
                    
                    // Alert for editing transaction amount
                    if isEditing {
                        CustomAlertView(
                            title: "Edit Amount",
                            textFieldValue: $newAmount,
                            onSave: {
                                if let transaction = editingTransaction {
                                    TransactionHelper.saveEditedTransaction(transaction, newAmount: newAmount, viewContext: viewContext, balances: balances)
                                }
                                isEditing = false
                            },
                            onCancel: {
                                isEditing = false
                            }
                        )
                    }
                    // Scroll view for displaying filtered transactions
                    ScrollView {
                        if !refreshData {
                            if filteredTransactions.isEmpty {
                                VStack {
                                    Image(systemName: "tray")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.green)
                                        .padding()
                                    
                                    Text("No Transactions Yet")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 65)
                            } else {
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(filteredTransactions) { transaction in
                                        VStack {
                                            HStack {
                                                Text(transaction.category ?? "Income")
                                                    .font(.headline)
                                                
                                                Spacer()
                                                
                                                Text("\(transaction.amount, specifier: "%.2f") $")
                                                    .font(.headline)
                                                    .foregroundColor(transaction.amount >= 0 ? .green : .red)
                                            }
                                            HStack {
                                                Text(transaction.date ?? Date(), style: .date)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                                
                                                Spacer()
                                                Button(action: {
                                                    (editingTransaction, newAmount) = TransactionHelper.startEditing(transaction: transaction)
                                                           isEditing = true
                                                }) {
                                                    
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 25, height: 25)
                                                            .foregroundColor(.green.opacity(0.4))
                                                        Image(systemName: "pencil")
                                                            .font(.system(size: 13))
                                                            .foregroundColor(Color("green1"))
                                                    }
                                                }
                                                .padding(.leading, 10)
                                                
                                                Button(action: {
                                                    TransactionHelper.deleteTransaction(transaction, viewContext: viewContext, balances: balances)
                                                }) {
                                                    
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 25, height: 25)
                                                            .foregroundColor(.red.opacity(0.4))
                                                        Image(systemName: "trash")
                                                            .font(.system(size: 13))
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                            .padding(.top, 5)
                                        }
                                        .padding()
                                        .background(.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 10)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}




