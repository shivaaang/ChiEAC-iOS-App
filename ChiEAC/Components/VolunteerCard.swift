//
//  VolunteerCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/21/25.
//

import SwiftUI

struct VolunteerCard: View {
    @State private var showVolunteerSheet = false
    @State private var volunteerURL: String? = nil

    var body: some View {
        Button {
            if volunteerURL != nil { showVolunteerSheet = true }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "figure.2.arms.open")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.chieacPrimary)
                    .padding(10)
                    .background(Color.chieacPrimary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Volunteer With Us")
                            .font(.chieacHero)
                            .foregroundColor(.chieacTextPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(volunteerURL != nil ? .chieacTextPrimary : .chieacTextSecondary.opacity(0.6))
                    }

                    Text("Lend your time and talent to help create lasting change for students.")
                        .font(.chieacBody)
                        .foregroundColor(.chieacTextSecondary)
                        .lineSpacing(2)
                }
            }
            .padding(16)
            .frame(minHeight: 80)
            .contentShape(Rectangle())
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(volunteerURL == nil)
        .sheet(isPresented: $showVolunteerSheet) {
            if let url = volunteerURL {
                ExternalLinkWebView(urlString: url, title: "Volunteer")
            } else {
                Text("Volunteer link unavailable.").padding()
            }
        }
        .onAppear {
            guard volunteerURL == nil else { return }
            Task {
                do {
                    let links = try await FirestoreRepository.shared.loadExternalLinks()
                    volunteerURL = links.first(where: { $0.name.lowercased() == "volunteer" })?.address
                } catch {
                    print("Error loading external links: \(error)")
                }
            }
        }
    }
}

struct VolunteerCard_Previews: PreviewProvider {
    static var previews: some View {
        VolunteerCard()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
