//
//  AddIncomeSheet.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 26.11.2024.
//

import SwiftUI
import CoreData

struct AddIncomeSheet: View {
    @State private var incomeAmount: String = ""
    @State private var selectedDate: Date = Date()
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var refreshData: Bool 
    
    var body: some View {
        
        // Wrap the form content
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                TextField("Enter amount", text: $incomeAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onChange(of: incomeAmount) { newValue in
                        incomeAmount = filterAmountInput(newValue)
                    }
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .padding(.horizontal)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .tint(.green)
                Spacer()
                
                // Button to add the income when pressed
                Button(action: {
                    if let amount = Double(incomeAmount) {
                        addIncome(amount: amount, selectedDate: selectedDate, viewContext: viewContext)
                        isPresented = false
                    }
                   
                }) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitle("Add Income", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
