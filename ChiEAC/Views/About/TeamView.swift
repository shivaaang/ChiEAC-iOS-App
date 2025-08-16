//
//  TeamView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/12/25.
//

import SwiftUI

struct TeamView: View {
    let team: Team
    let members: [TeamMember]
    @State private var selectedMember: TeamMember?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(team.name)
                    .font(.chieacAppTitle)
                    .foregroundColor(.chieacPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                ForEach(members, id: \.id) { member in
                    TeamMemberCard(
                        member: member,
                        onMoreTap: { selectedMember = member },
                        onCardTap: { selectedMember = member }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.chieacLightBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedMember) { member in
            TeamMemberDetailView(member: member)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // Email/phone actions removed per new schema
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        let team = Team(id: "team.core_team", name: "Core Team", code: .coreTeam, description: "desc", order: 1)
        let members: [TeamMember] = [
            TeamMember(id: "m1", name: "Jane Doe", title: "Role", bio: "Long bio here", bioShort: nil, team: .coreTeam, imageURL: nil, order: 1),
            TeamMember(id: "m2", name: "John Doe", title: "Role", bio: "Longer bio here", bioShort: nil, team: .coreTeam, imageURL: nil, order: 2)
        ]
        NavigationView { TeamView(team: team, members: members) }
    }
}
