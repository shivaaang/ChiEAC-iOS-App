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
            // Header with avatar, info, and More button
            HStack(alignment: .top, spacing: 16) {
                // Avatar using cached component with circular clipping
                CachedImageView(
                    imageURL: member.imageURL,
                    name: member.name,
                    width: 60
                )
                .clipShape(Circle())
                
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
                
                // More button in top-right corner (only if there is a longer bio available)
                if let short = member.bioShort, !short.isEmpty, short != member.bio, let onMoreTap {
                    Button(action: onMoreTap) {
                        HStack(spacing: 4) {
                            Text("More")
                                .font(.chieacCaption)
                                .foregroundColor(.chieacSecondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.chieacSecondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.chieacSecondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("More details about \(member.name)")
                }
            }
            
            // Summary (prefer short summary if available) - now full width
            Text(member.bioShort ?? member.bio)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
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
