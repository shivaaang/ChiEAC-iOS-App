//
//  ContactFormComponents.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/18/25.
//

import SwiftUI

// MARK: - Form Field Components

struct FormFieldRow: View {
    let fields: [AnyView]
    let spacing: CGFloat
    
    init(spacing: CGFloat = 12, @ViewBuilder content: () -> [AnyView]) {
        self.fields = content()
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<fields.count, id: \.self) { index in
                fields[index]
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct FormPhoneField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let errorMessage: String?
    let isOptional: Bool
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil,
        isOptional: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
        self.isOptional = isOptional
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.chieacBodySecondary)
                    .foregroundColor(.chieacTextPrimary)
                
                if !isOptional {
                    Text("*")
                        .font(.chieacBodySecondary)
                        .foregroundColor(.red)
                }
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(ChiEACTextFieldStyle(hasError: errorMessage != nil))
                .keyboardType(.numberPad)
                .onChange(of: text) { _, newValue in
                    // Format phone number as user types
                    let formatted = formatPhoneNumber(newValue)
                    if formatted != newValue {
                        text = formatted
                    }
                }
            
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.chieacCaption)
                        .foregroundColor(.red)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
    
    private func formatPhoneNumber(_ input: String) -> String {
        // Remove all non-numeric characters
        let digits = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Limit to 10 digits
        let limitedDigits = String(digits.prefix(10))
        
        // Format based on length
        switch limitedDigits.count {
        case 0:
            return ""
        case 1...3:
            return "(\(limitedDigits)"
        case 4...6:
            let area = String(limitedDigits.prefix(3))
            let exchange = String(limitedDigits.suffix(limitedDigits.count - 3))
            return "(\(area)) \(exchange)"
        case 7...10:
            let area = String(limitedDigits.prefix(3))
            let exchange = String(limitedDigits.dropFirst(3).prefix(3))
            let number = String(limitedDigits.suffix(limitedDigits.count - 6))
            return "(\(area)) \(exchange)-\(number)"
        default:
            return limitedDigits
        }
    }
}

struct FormTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let errorMessage: String?
    let keyboardType: UIKeyboardType
    let isOptional: Bool
    let autocapitalization: TextInputAutocapitalization
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isOptional: Bool = false,
        autocapitalization: TextInputAutocapitalization = .words
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
        self.keyboardType = keyboardType
        self.isOptional = isOptional
        self.autocapitalization = autocapitalization
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.chieacBodySecondary)
                    .foregroundColor(.chieacTextPrimary)
                
                if !isOptional {
                    Text("*")
                        .font(.chieacBodySecondary)
                        .foregroundColor(.red)
                }
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(ChiEACTextFieldStyle(hasError: errorMessage != nil))
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(autocapitalization)
            
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.chieacCaption)
                        .foregroundColor(.red)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}

struct FormTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let errorMessage: String?
    let minHeight: CGFloat
    let isOptional: Bool
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil,
        minHeight: CGFloat = 100,
        isOptional: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
        self.minHeight = minHeight
        self.isOptional = isOptional
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.chieacBodySecondary)
                    .foregroundColor(.chieacTextPrimary)
                
                if !isOptional {
                    Text("*")
                        .font(.chieacBodySecondary)
                        .foregroundColor(.red)
                }
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.red : Color.chieacTextSecondary.opacity(0.3), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.chieacTextSecondary.opacity(0.6))
                        .font(.chieacBody)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $text)
                    .font(.chieacBody)
                    .foregroundColor(.chieacTextPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: minHeight)
            
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.chieacCaption)
                        .foregroundColor(.red)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}

// MARK: - Custom Text Field Style

struct ChiEACTextFieldStyle: TextFieldStyle {
    let hasError: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.chieacBody)
            .foregroundColor(.chieacTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(hasError ? Color.red : Color.chieacTextSecondary.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Form Submit Button

struct FormSubmitButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.chieacButtonText)
                    .opacity(isLoading ? 0.7 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? Color.chieacPrimary : Color.chieacPrimary.opacity(0.8))
            )
            .shadow(color: isEnabled ? .chieacPrimary.opacity(0.3) : .chieacPrimary.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Form Header

struct FormHeader: View {
    let title: String
    let subtitle: String?
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image("chieac-logo-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.chieacSectionHeader)
                    .foregroundColor(.chieacPrimary)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.chieacBody)
                    .foregroundColor(.chieacTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Success Animation View

struct SuccessAnimationView: View {
    @State private var showCheckmark = false
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.chieacSuccess.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(Color.chieacSuccess, lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .scaleEffect(scale)
                
                if showCheckmark {
                    Image(systemName: "checkmark")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.chieacSuccess)
                        .scaleEffect(scale)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        showCheckmark = true
                    }
                }
            }
            
            Text("Success!")
                .font(.chieacCardTitle)
                .foregroundColor(.chieacSuccess)
                .opacity(showCheckmark ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3).delay(0.4), value: showCheckmark)
        }
    }
}
