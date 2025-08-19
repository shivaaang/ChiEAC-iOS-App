//
//  GetInTouchCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/18/25.
//

import SwiftUI

struct GetInTouchCard: View {
    let contactEmail: String?
    let contactPhone: String?
    
    @State private var showContactForm = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Get In Touch")
                    .font(.chieacHero)
                    .foregroundColor(.chieacTextPrimary)
                
                Text("We'd love to hear from you")
                    .font(.chieacBody)
                    .foregroundColor(.chieacTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Contact Options
            VStack(spacing: 0) {
                // Email
                if let email = contactEmail {
                    ContactOptionButton(
                        icon: "envelope.fill",
                        title: email,
                        subtitle: nil,
                        color: .chieacSecondary
                    ) {
                        openEmail(email)
                    }
                }
                
                // Phone
                if let phone = contactPhone {
                    ContactOptionButton(
                        icon: "phone.fill",
                        title: phone,
                        subtitle: nil,
                        color: .chieacSecondary
                    ) {
                        openPhone(phone)
                    }
                }
                
                // Contact Form
                ContactOptionButton(
                    icon: "message.fill",
                    title: "Send Us a Message",
                    subtitle: nil,
                    color: .chieacPrimary
                ) {
                    showContactForm = true
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .chieacPrimary.opacity(0.08), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showContactForm) {
            ContactFormView(
                source: .general,
                sourceString: "send_a_message",
                customTitle: "Send Us a Message"
            )
        }
    }
    
    private func openEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPhone(_ phone: String) {
        // Clean phone number for tel: scheme
        let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ContactOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Text Content
                if let subtitle = subtitle {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.chieacTextPrimary)
                        
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.chieacTextSecondary)
                    }
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.chieacTextPrimary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.chieacTextSecondary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle()) // This makes the entire area tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct GetInTouchCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            GetInTouchCard(
                contactEmail: "info@chieac.org",
                contactPhone: "+1 (773) 599-0267"
            )
            .padding()
        }
        .background(Color.chieacLightBackground)
        .previewDisplayName("Get In Touch Card - Compact")
    }
}
