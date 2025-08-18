//
//  TeamMemberCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct TeamMemberCard: View {
    let member: TeamMember
    let onMoreTap: (() -> Void)?
    let onCardTap: () -> Void
    
    var body: some View {
    VStack(alignment: .leading, spacing: 16) {
            // Header with avatar and basic info
            HStack(alignment: .top, spacing: 16) {
                // Avatar - only show if image is available and loads successfully
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.chieacPrimary, .chieacSecondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    if let imageURL = member.imageURL, !imageURL.isEmpty {
                        // Only show if we have a valid image URL
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                // Only show the image if it loaded successfully
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 60, height: 60)
                            case .empty, .failure(_):
                                // Show initials for loading or failed states
                                Text(getInitials(from: member.name))
                                    .font(.chieacCardTitle)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            @unknown default:
                                Text(getInitials(from: member.name))
                                    .font(.chieacCardTitle)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                    } else {
                        // No image URL - show initials
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
            
            // Summary (prefer short summary if available)
            Text(member.bioShort ?? member.bio)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(2)
            
            // Footer: More… link when there is a shorter summary
            HStack(spacing: 12) {
                Spacer()

                // Show More… only if there is a longer bio available
                if let short = member.bioShort, !short.isEmpty, short != member.bio, let onMoreTap {
                    Button(action: onMoreTap) {
                        HStack(spacing: 4) {
                            Text("More…")
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                        }
                        .font(.chieacCaption)
                        .foregroundColor(.chieacSecondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("More details about \(member.name)")
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    .contentShape(Rectangle())
    .onTapGesture { onCardTap() }
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel("Open details for \(member.name)")
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map(String.init)
    return initials.prefix(2).joined().uppercased()
    }
}

struct TeamMemberCard_Previews: PreviewProvider {
    static var previews: some View {
        TeamMemberCard(
            member: TeamMember(
                id: "member.core_team.benjamin_drury",
                name: "Benjamin (Dr. D) Drury",
                title: "Founder & Executive Director",
                bio: "Founded ChiEAC in 2020 with passion for addressing systemic educational inequities.",
                bioShort: "Founded ChiEAC in 2020…",
                team: "core_team",
                imageURL: nil,
                order: 1
            ),
            onMoreTap: { print("More tapped") },
            onCardTap: { print("Card tapped") }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
