//
//  CustomAlertView.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 26.11.2024.
//

import SwiftUI

//Alert for editing
struct CustomAlertView: View {
    var title: String
    @Binding var textFieldValue: String
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            
            TextField("Enter new amount", text: $textFieldValue)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundColor(.red)
                Spacer()
                
                Button("Save", action: onSave)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

