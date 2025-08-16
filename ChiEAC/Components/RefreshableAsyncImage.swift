//
//  RefreshableAsyncImage.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/16/25.
//

import SwiftUI

// Simple content/placeholder version
struct RefreshableAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var refreshID = UUID()
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
            case .failure(_):
                placeholder()
            @unknown default:
                placeholder()
            }
        }
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: .refreshImages)) { _ in
            refreshID = UUID()
        }
    }
}

// Phase-based version for complex async image handling
struct RefreshableAsyncImageWithPhase<Content: View>: View {
    let url: URL?
    let content: (AsyncImagePhase) -> Content
    
    @State private var refreshID = UUID()
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            content(phase)
        }
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: .refreshImages)) { _ in
            refreshID = UUID()
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let refreshImages = Notification.Name("refreshImages")
}
