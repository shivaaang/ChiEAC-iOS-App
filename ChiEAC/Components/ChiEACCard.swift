//
//  ChiEACCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct ChiEACCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// Note: This is a wrapper component - it doesn't contain Text elements itself,
// so it doesn't need typography system updates. The content passed into it
// will use the typography system.

struct ChiEACCard_Previews: PreviewProvider {
    static var previews: some View {
        ChiEACCard {
            Text("Sample Card Content")
                .font(.chieacBody)  // Typography system used in the content
        }
        .padding()
    }
}
