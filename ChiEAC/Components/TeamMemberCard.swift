//
//  TeamMemberCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct TeamMemberCard: View {
    let member: TeamMember
    let onEmailTap: () -> Void
    let onPhoneTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with avatar and basic info
            HStack(alignment: .top, spacing: 16) {
                // Avatar (with image support)
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.chieacPrimary, .chieacSecondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    if let imageURL = member.imageURL, let url = URL(string: imageURL) {
                        // Show actual photo if available
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                        } placeholder: {
                            // Show loading indicator while image loads
                            ProgressView()
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 60)
                    } else {
                        // Fallback to initials if no image
                        Text(getInitials(from: member.name))
                            .font(.chieacCardTitle)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(member.name)
                        .font(.chieacCardTitle)
                        .foregroundColor(.chieacTextPrimary)
                    
                    Text(member.title)
                        .font(.chieacCardSubtitle)
                        .foregroundColor(.chieacSecondary)
                }
                
                Spacer()
            }
            
            // Bio
            Text(member.bio)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(2)
            
            // Contact buttons
            HStack(spacing: 12) {
                if !member.email.isEmpty {
                    ContactButton(
                        icon: "envelope.fill",
                        action: onEmailTap
                    )
                }
                
                if let phone = member.phone, !phone.isEmpty {
                    ContactButton(
                        icon: "phone.fill",
                        action: onPhoneTap
                    )
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.chieacCardGreen)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map(String.init)
        return initials.prefix(2).joined()
    }
}

struct ContactButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.chieacCaption)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.chieacSecondary)
                .clipShape(Circle())
        }
    }
}

struct TeamMemberCard_Previews: PreviewProvider {
    static var previews: some View {
        TeamMemberCard(
            member: TeamMember(
                name: "Benjamin (Dr. D) Drury",
                title: "Founder & Executive Director",
                bio: "Founded ChiEAC in 2020 with passion for addressing systemic educational inequities.",
                email: "benjamin@chieac.org",
                phone: "312-555-0123",
                type: .core,
                imageURL: nil
            ),
            onEmailTap: { print("Email tapped") },
            onPhoneTap: { print("Phone tapped") }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}