//
//  ImmigrationHelpCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/21/25.
//

import SwiftUI

struct ImmigrationHelpCard: View {
    @State private var showImmigrationSheet = false
    @State private var immigrationURL: String? = nil

    var body: some View {
        Button {
            if immigrationURL != nil { showImmigrationSheet = true }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.chieacPrimary)
                    .padding(10)
                    .background(Color.chieacPrimary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Immigration Legal Help")
                            .font(.chieacHero)
                            .foregroundColor(.chieacTextPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(immigrationURL != nil ? .chieacTextPrimary : .chieacTextSecondary.opacity(0.6))
                    }

                    Text("Free legal support and Know Your Rights resources from TRP Immigrant Justice.")
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
        .disabled(immigrationURL == nil)
        .sheet(isPresented: $showImmigrationSheet) {
            if let url = immigrationURL {
                ExternalLinkWebView(urlString: url, title: "Immigration Legal Help")
            } else {
                Text("Immigration help link unavailable.").padding()
            }
        }
        .onAppear {
            guard immigrationURL == nil else { return }
            Task {
                do {
                    let links = try await FirestoreRepository.shared.loadExternalLinks()
                    immigrationURL = links.first(where: { $0.name.lowercased() == "immigrant_justice" })?.address
                } catch {
                    print("Error loading external links: \(error)")
                }
            }
        }
    }
}

struct ImmigrationHelpCard_Previews: PreviewProvider {
    static var previews: some View {
        ImmigrationHelpCard()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
