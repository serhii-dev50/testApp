//
//  AddExpenseSheet.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 26.11.2024.
//

import SwiftUI
import CoreData

// A view for adding a new expense or managing categories in the expense manager app
struct AddExpenseSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedCategory: String = "Food"
    @State private var newCategory: String = ""
    @State private var showAddCategoryAlert = false
    @State private var incomeAmount: String = ""

    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)])
    private var categories: FetchedResults<Category>

    private var expenseManager: ExpenseManager

    init(isPresented: Binding<Bool>, viewContext: NSManagedObjectContext) {
        self._isPresented = isPresented
        self.expenseManager = ExpenseManager(viewContext: viewContext)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter amount", text: $incomeAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: incomeAmount) { newValue in
                        incomeAmount = filterAmountInput(newValue)
                    }

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.name) { category in
                        Text(category.name ?? "")
                            .tag(category.name ?? "")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack(spacing: 35) {
                    Button("Add Category") {
                        showAddCategoryAlert = true
                    }
                    .font(.system(size: 15))
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 130)
                    .background(.green)
                    .cornerRadius(10)

                    Button("Remove Category") {
                        expenseManager.removeCategory(named: selectedCategory, categories: categories, viewContext: viewContext)
                    }
                    .font(.system(size: 15))
                    .bold()
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: 130)
                    .background(.red.opacity(0.2))
                    .cornerRadius(10)
                    .disabled(categories.count <= 1)
                }
                .padding(.top, 30)
                Spacer()

                Button(action: {
                    expenseManager.saveExpense(amount: incomeAmount, selectedCategory: selectedCategory, isPresented: $isPresented)
                }) {
                    Text("Save")
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
            .navigationBarTitle("Add Expense", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
            .alert("Add New Category", isPresented: $showAddCategoryAlert) {
                TextField("Category Name", text: $newCategory)
                Button("Add", action: {
                    expenseManager.addCategory(newCategory: newCategory, categories: categories, viewContext: viewContext)
                })
                Button("Cancel", role: .cancel, action: {})
            }
        }
    }
}
