//
//  ContactFormViewModel.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/18/25.
//

import Foundation
import SwiftUI

@MainActor
class ContactFormViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var message: String = ""
    
    // MARK: - State Properties
    @Published var isSubmitting: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Validation Properties
    @Published var firstNameError: String? = nil
    @Published var lastNameError: String? = nil
    @Published var emailError: String? = nil
    @Published var phoneError: String? = nil
    @Published var messageError: String? = nil
    
    // MARK: - Dependencies
    private let repository: FirestoreRepositoryProtocol
    let source: ContactFormSource
    let sourceString: String // The actual source string to save to database
    private let customTitle: String?
    
    // MARK: - Computed Properties
    var configuration: ContactFormConfiguration {
        let baseConfig = ContactFormConfiguration.configuration(for: source)
        if let customTitle = customTitle {
            return ContactFormConfiguration(
                title: customTitle,
                submitButtonText: baseConfig.submitButtonText,
                successMessage: baseConfig.successMessage,
                messagePlaceholder: baseConfig.messagePlaceholder
            )
        }
        return baseConfig
    }
    var isFormValid: Bool {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic non-empty validation
        guard !trimmedFirstName.isEmpty,
              !trimmedLastName.isEmpty,
              !trimmedEmail.isEmpty,
              !trimmedMessage.isEmpty else {
            return false
        }
        
        // Length validations
        guard trimmedFirstName.count >= 2,
              trimmedLastName.count >= 2,
              trimmedMessage.count >= 10 else {
            return false
        }
        
        // Email validation
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            return false
        }
        
        // Phone validation (optional field)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedPhone.isEmpty {
            let digitsOnly = trimmedPhone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            guard digitsOnly.count >= 10 && digitsOnly.count <= 15 else {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Initialization
    init(source: ContactFormSource, sourceString: String? = nil, customTitle: String? = nil, repository: FirestoreRepositoryProtocol = FirestoreRepository.shared) {
        self.source = source
        self.sourceString = sourceString ?? source.rawValue
        self.customTitle = customTitle
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func submitForm() async {
        // Always validate all fields when user tries to submit
        validateAllFields()
        
        guard isFormValid else {
            // Form is invalid, provide haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            return
        }
        
        isSubmitting = true
        errorMessage = ""
        
        do {
            let submission = ContactFormSubmission(
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                source: sourceString
            )
            
            try await repository.submitContactForm(submission)
            
            // Success haptic feedback
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            showSuccessAlert = true
            clearForm()
            
        } catch {
            // Error haptic feedback
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
            
            errorMessage = "Failed to submit form. Please check your internet connection and try again."
            showErrorAlert = true
            print("❌ Form submission failed: \(error)")
        }
        
        isSubmitting = false
    }
    
    func validateAllFields() {
        firstNameError = validateFirstName()
        lastNameError = validateLastName()
        emailError = validateEmail()
        phoneError = validatePhone()
        messageError = validateMessage()
    }
    
    func clearForm() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        message = ""
        clearValidationErrors()
    }
    
    func clearValidationErrors() {
        firstNameError = nil
        lastNameError = nil
        emailError = nil
        phoneError = nil
        messageError = nil
    }
    
    // MARK: - Validation Methods
    private func validateFirstName() -> String? {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "First name is required"
        }
        if trimmed.count < 2 {
            return "First name must be at least 2 characters"
        }
        if trimmed.count > 50 {
            return "First name must be less than 50 characters"
        }
        if !trimmed.allSatisfy({ $0.isLetter || $0.isWhitespace || $0 == "-" || $0 == "'" }) {
            return "First name can only contain letters, spaces, hyphens, and apostrophes"
        }
        return nil
    }
    
    private func validateLastName() -> String? {
        let trimmed = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Last name is required"
        }
        if trimmed.count < 2 {
            return "Last name must be at least 2 characters"
        }
        if trimmed.count > 50 {
            return "Last name must be less than 50 characters"
        }
        if !trimmed.allSatisfy({ $0.isLetter || $0.isWhitespace || $0 == "-" || $0 == "'" }) {
            return "Last name can only contain letters, spaces, hyphens, and apostrophes"
        }
        return nil
    }
    
    private func validateEmail() -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Email is required"
        }
        
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: trimmed) {
            return "Please enter a valid email address"
        }
        return nil
    }
    
    private func validatePhone() -> String? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil // Phone is optional
        }
        
        // Remove all non-digit characters for validation
        let digitsOnly = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if digitsOnly.count < 10 {
            return "Phone number must be 10 digits"
        }
        if digitsOnly.count > 10 {
            return "Phone number cannot exceed 10 digits"
        }
        return nil
    }
    
    private func validateMessage() -> String? {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Message is required"
        }
        if trimmed.count < 10 {
            return "Message must be at least 10 characters"
        }
        if trimmed.count > 1000 {
            return "Message must be less than 1000 characters"
        }
        return nil
    }
}

// MARK: - Form Configuration
struct ContactFormConfiguration {
    let title: String
    let submitButtonText: String
    let successMessage: String
    let messagePlaceholder: String
    
    static func configuration(for source: ContactFormSource) -> ContactFormConfiguration {
        switch source {
        case .getHelp:
            return ContactFormConfiguration(
                title: "Get Help",
                submitButtonText: "Submit Request",
                successMessage: "Your help request has been submitted. We'll get back to you soon!",
                messagePlaceholder: "Describe how we can help you..."
            )
        case .programInquiry:
            return ContactFormConfiguration(
                title: "Program Information",
                submitButtonText: "Send Inquiry",
                successMessage: "Your program inquiry has been sent. We'll get in touch shortly.",
                messagePlaceholder: "Tell us a bit about yourself. Do you have any questions for us?"
            )
        case .volunteer:
            return ContactFormConfiguration(
                title: "Volunteer With Us",
                submitButtonText: "Submit Application",
                successMessage: "Thank you for your interest in volunteering! We'll be in touch soon.",
                messagePlaceholder: "Tell us about your interests and how you'd like to help..."
            )
        case .general:
            return ContactFormConfiguration(
                title: "Contact Us",
                submitButtonText: "Send Message",
                successMessage: "Your message has been sent. We'll respond as soon as possible!",
                messagePlaceholder: "What would you like to discuss?"
            )
        case .partnership:
            return ContactFormConfiguration(
                title: "Partnership Inquiry",
                submitButtonText: "Submit Inquiry",
                successMessage: "Thank you for your partnership interest! We'll review and respond soon.",
                messagePlaceholder: "Tell us about your organization and partnership ideas..."
            )
        }
    }
}
