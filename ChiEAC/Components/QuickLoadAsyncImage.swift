//
//  QuickLoadAsyncImage.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/18/25.
//

import SwiftUI
import Combine

struct QuickLoadAsyncImage<Content: View>: View {
    let url: URL?
    let content: (AsyncImagePhase) -> Content
    let timeout: TimeInterval
    
    @State private var phase: AsyncImagePhase = .empty
    @State private var cancellable: AnyCancellable?
    
    init(
        url: URL?,
        timeout: TimeInterval = 3.0, // Quick 3-second timeout
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.timeout = timeout
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
            .onChange(of: url) {
                loadImage()
            }
    }
    
    private func loadImage() {
        // Cancel any existing request
        cancellable?.cancel()
        
        guard let url = url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        // Start with empty phase
        phase = .empty
        
        // Create a timeout publisher
        let timeoutPublisher = Just(())
            .delay(for: .seconds(timeout), scheduler: DispatchQueue.main)
            .map { _ in AsyncImagePhase.failure(URLError(.timedOut)) }
        
        // Create the image loading publisher
        let imagePublisher = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .map { Image(uiImage: $0) }
            .map { AsyncImagePhase.success($0) }
            .catch { error in
                Just(AsyncImagePhase.failure(error))
            }
            .receive(on: DispatchQueue.main)
        
        // Race between image loading and timeout
        cancellable = Publishers.Merge(imagePublisher, timeoutPublisher)
            .first()
            .sink { newPhase in
                self.phase = newPhase
            }
    }
}
