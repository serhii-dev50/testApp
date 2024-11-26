//
//  StatisticsView.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 25.11.2024.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    let transactions: FetchedResults<Transaction>
    @Binding var isPresented: Bool
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)])
    private var categories: FetchedResults<Category>
    @State private var selectedStartDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var selectedEndDate: Date = Date()

    // Filter transactions based on the selected date range
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= selectedStartDate && date <= selectedEndDate
        }
    }

    // Categorize transactions and sum amounts per category
    var categorizedData: [String: Double] {
        var data: [String: Double] = [:]
        for transaction in filteredTransactions {
            let category = transaction.category ?? "Income"
            data[category, default: 0.0] += transaction.amount
        }
        return data
    }

    // Calculate total income (transactions with positive amounts)
    var totalIncome: Double {
        filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }

    // Calculate total expenses (transactions with negative amounts)
    var totalExpenses: Double {
        filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            VStack {
                
                // Date Pickers for filtering transactions by start and end dates
                HStack {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .tint(.green)
                            .labelsHidden()
                    }
                    Spacer()

                    VStack(alignment: .leading) {
                        Text("End Date")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        DatePicker("", selection: $selectedEndDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .tint(.green)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal, 20)
                
                // Display total income and expenses
                VStack(alignment: .leading) {
                    Text("Total Income: \(totalIncome, specifier: "%.2f") $")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text("Total Expenses: \(totalExpenses, specifier: "%.2f") $")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()

                // Display a chart for categorized data
                Chart {
                    ForEach(categorizedData.keys.sorted(), id: \.self) { category in
                        if let value = categorizedData[category] {
                            SectorMark(
                                angle: .value("Value", value),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(category == "Income" ? .green : .red)
                            .annotation(position: .overlay) {
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: 300)
                .padding()

                Spacer()

                // Button to close the view
                Button(action: {
                    isPresented = false
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
