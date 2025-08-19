//
//  ContactFormView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/18/25.
//

import SwiftUI

struct ContactFormView: View {
    let source: ContactFormSource
    let sourceString: String
    let customTitle: String?
    @StateObject private var viewModel: ContactFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FormField?
    
    init(source: ContactFormSource, sourceString: String? = nil, customTitle: String? = nil) {
        self.source = source
        let finalSourceString = sourceString ?? source.rawValue
        self.sourceString = finalSourceString
        self.customTitle = customTitle
        self._viewModel = StateObject(wrappedValue: ContactFormViewModel(source: source, sourceString: finalSourceString, customTitle: customTitle))
    }
    
    // Native iOS-style keyboard toolbar
    private var nativeKeyboardToolbar: some View {
        HStack(spacing: 0) {
            // Previous button
            Button(action: moveToPrevious) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(canMovePrevious ? .blue : .gray)
                    .frame(width: 44, height: 44)
            }
            .disabled(!canMovePrevious)
            
            // Next button  
            Button(action: moveToNext) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(canMoveNext ? .blue : .gray)
                    .frame(width: 44, height: 44)
            }
            .disabled(!canMoveNext)
            
            Spacer()
            
            // Done button
            Button("Done") {
                focusedField = nil
            }
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.blue)
        }
        .frame(height: 44)
        .background(Color(UIColor.systemBackground))
    }
    
    // Navigation logic
    private var canMovePrevious: Bool {
        focusedField?.previous != nil
    }
    
    private var canMoveNext: Bool {
        focusedField?.next != nil
    }
    
    private func moveToPrevious() {
        guard let currentField = focusedField,
              let previousField = currentField.previous else { return }
        focusedField = previousField
    }
    
    private func moveToNext() {
        guard let currentField = focusedField,
              let nextField = currentField.next else { return }
        focusedField = nextField
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.chieacLightBackground
                    .ignoresSafeArea()
                
                if viewModel.showSuccessAlert {
                    // Success state
                    VStack(spacing: 24) {
                        SuccessAnimationView()
                        
                        VStack(spacing: 12) {
                            Text(viewModel.configuration.successMessage)
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 40)
                    .transition(.opacity.combined(with: .scale))
                } else {
                    // Form state
                    ScrollView {
                        VStack(spacing: 24) {
                            FormHeader(
                                title: viewModel.configuration.title,
                                subtitle: "We'll get back to you as soon as possible."
                            )
                            
                            VStack(spacing: 16) {
                                // First Name and Last Name on same line
                                HStack(spacing: 12) {
                                    FormTextField(
                                        title: "First Name",
                                        placeholder: "First name",
                                        text: $viewModel.firstName,
                                        errorMessage: viewModel.firstNameError,
                                        autocapitalization: .words
                                    )
                                    .focused($focusedField, equals: .firstName)
                                    .frame(maxWidth: .infinity)
                                    
                                    FormTextField(
                                        title: "Last Name",
                                        placeholder: "Last name",
                                        text: $viewModel.lastName,
                                        errorMessage: viewModel.lastNameError,
                                        autocapitalization: .words
                                    )
                                    .focused($focusedField, equals: .lastName)
                                    .frame(maxWidth: .infinity)
                                }
                                
                                // Email
                                FormTextField(
                                    title: "Email",
                                    placeholder: "Enter your email address",
                                    text: $viewModel.email,
                                    errorMessage: viewModel.emailError,
                                    keyboardType: .emailAddress,
                                    autocapitalization: .never
                                )
                                .focused($focusedField, equals: .email)
                                
                                // Phone with professional formatting
                                FormPhoneField(
                                    title: "Phone",
                                    placeholder: "(555) 123-4567",
                                    text: $viewModel.phone,
                                    errorMessage: viewModel.phoneError,
                                    isOptional: true
                                )
                                .focused($focusedField, equals: .phone)
                                
                                // Message
                                FormTextEditor(
                                    title: "Message",
                                    placeholder: viewModel.configuration.messagePlaceholder,
                                    text: $viewModel.message,
                                    errorMessage: viewModel.messageError,
                                    minHeight: 120
                                )
                                .focused($focusedField, equals: .message)
                            }
                            .padding(.horizontal, 20)
                            
                            // Submit Button (always enabled, validation happens on press)
                            FormSubmitButton(
                                title: viewModel.configuration.submitButtonText,
                                isEnabled: true,
                                isLoading: viewModel.isSubmitting
                            ) {
                                Task {
                                    await viewModel.submitForm()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Required fields note
                            HStack(spacing: 4) {
                                Text("*")
                                    .font(.chieacCaption)
                                    .foregroundColor(.red)
                                
                                Text("Required fields")
                                    .font(.chieacCaption)
                                    .foregroundColor(.chieacTextSecondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.chieacPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if focusedField != nil {
                        Button("Done") {
                            focusedField = nil
                        }
                        .foregroundColor(.chieacPrimary)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if focusedField != nil {
                        nativeKeyboardToolbar
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.showErrorAlert = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showSuccessAlert)
        .onChange(of: viewModel.firstName) { _, _ in viewModel.firstNameError = nil }
        .onChange(of: viewModel.lastName) { _, _ in viewModel.lastNameError = nil }
        .onChange(of: viewModel.email) { _, _ in viewModel.emailError = nil }
        .onChange(of: viewModel.phone) { _, _ in viewModel.phoneError = nil }
        .onChange(of: viewModel.message) { _, _ in viewModel.messageError = nil }
    }
}

// MARK: - Form Fields Enum

enum FormField: Hashable, CaseIterable {
    case firstName, lastName, email, phone, message
    
    var next: FormField? {
        let allCases = FormField.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < allCases.count ? allCases[nextIndex] : nil
    }
    
    var previous: FormField? {
        let allCases = FormField.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? allCases[previousIndex] : nil
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.chieacButtonSecondary)
            .foregroundColor(.chieacPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.chieacPrimary, lineWidth: 1.5)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .contentShape(Rectangle())
    }
}

// MARK: - Preview

struct ContactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView(source: .getHelp)
    }
}
