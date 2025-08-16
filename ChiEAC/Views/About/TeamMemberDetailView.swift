//
//  TeamMemberDetailView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/12/25.
//

import SwiftUI

struct TeamMemberDetailView: View {
    let member: TeamMember
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.chieacLightBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Image section
                ZStack(alignment: .topTrailing) {
                    memberImage
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    closeButton
                        .padding(12)
                }

                // Details section
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(member.name)
                            .font(.title.bold())
                            .foregroundColor(.chieacTextPrimary)

                        Text(member.title)
                            .font(.headline)
                            .foregroundColor(.chieacSecondary)

                        Divider()

                        Text(member.bio)
                            .font(.chieacBody)
                            .foregroundColor(.chieacTextSecondary)
                            .lineSpacing(4)
                    }
                    .padding(20)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(20)
        }
    }

    @ViewBuilder
    private var memberImage: some View {
    if let link = member.imageURL, let url = URL(string: link) {
        AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
            initialsPlaceholder(size: 250)
                case .empty:
                    ProgressView()
                        .frame(width: 250, height: 250)
                        .background(Color(UIColor.systemGray5))
                @unknown default:
                    EmptyView()
                }
            }
        } else {
        initialsPlaceholder(size: 250)
        }
    }

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
                .shadow(radius: 5)
                .accessibilityLabel("Close")
                .accessibilityAddTraits(.isButton)
        }
    }
}

struct TeamMemberDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let member = TeamMember(
            id: "member.core_team.jane_doe",
            name: "Jane Doe",
            title: "Program Director",
            bio: "Jane has over a decade of experience leading community-based education initiatives across Chicago. She focuses on building partnerships and mentoring first-generation students.",
            bioShort: "Program Director with 10+ years of experience.",
            team: .coreTeam,
            imageURL: nil,
            order: 1
        )
        TeamMemberDetailView(member: member)
            .background(Color.gray.opacity(0.5))
    }
}

// MARK: - Local helpers
extension TeamMemberDetailView {
    private func initialsPlaceholder(size: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [.chieacPrimary, .chieacSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(initials(from: member.name))
                .font(.system(size: size / 3, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(height: size)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.compactMap { $0.first }.map { String($0) }
        return letters.prefix(2).joined().uppercased()
    }
}
