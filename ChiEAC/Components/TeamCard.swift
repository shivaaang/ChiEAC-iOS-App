//
//  TeamCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/12/25.
//

import SwiftUI

struct TeamCard: View {
    let team: Team
    let members: [TeamMember] // used for small avatar strip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(team.name)
                .font(.chieacHero)
                .foregroundColor(.chieacTextPrimary)
            
            // Description
            Text(team.description)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Avatar strip
            HStack(spacing: -8) {
                ForEach(Array(members.prefix(10)).indices, id: \.self) { idx in
                    let m = members[idx]
                    AvatarBubble(imageURL: m.imageURL, name: m.name)
                        .zIndex(Double(members.count - idx))
                }
                Spacer()
            }
            .padding(.top, 6)
            
            // CTA
            HStack {
                Text("Meet the team →")
                    .font(.chieacBody)
                    .foregroundColor(.chieacSecondary)
                Spacer()
            }
            .padding(.top, 6)
        }
        .padding(20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.chieacMintGreen.opacity(0.6), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.chieacCardGreen)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

private struct AvatarBubble: View {
    let imageURL: String?
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.chieacSecondary)
                .frame(width: 32, height: 32)
            if let imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView().scaleEffect(0.6)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            } else {
                Text(initials(name))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func initials(_ name: String) -> String {
        let comps = name.split(separator: " ")
        return comps.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
    }
}

struct TeamCard_Previews: PreviewProvider {
    static var previews: some View {
        let team = Team(id: "team.core_team", name: "Core Team", code: .coreTeam, description: "Meet the exceptionally dedicated team of educators...")
        let members: [TeamMember] = [
            TeamMember(id: "m1", name: "Jane Doe", title: "Role", bio: "bio", team: .coreTeam, imageURL: nil),
            TeamMember(id: "m2", name: "John Doe", title: "Role", bio: "bio", team: .coreTeam, imageURL: nil)
        ]
        TeamCard(team: team, members: members)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
