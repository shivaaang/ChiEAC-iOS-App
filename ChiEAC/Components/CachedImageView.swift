//
//  CachedImageView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/19/25.
//

import SwiftUI
import Kingfisher

/// A simple cached image component using Kingfisher for efficient image loading and caching
/// Stores images as-is and lets the UI layer handle any shape clipping
struct CachedImageView: View {
    let imageURL: String?
    let name: String
    let width: CGFloat?
    let height: CGFloat?
    let placeholderColor: Color
    
    init(
        imageURL: String?,
        name: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        placeholderColor: Color = .chieacSecondary
    ) {
        self.imageURL = imageURL
        self.name = name
        self.width = width
        self.height = height
        self.placeholderColor = placeholderColor
    }
    
    var body: some View {
        if let imageURL = imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
            KFImage(url)
                .placeholder {
                    // Show initials placeholder while loading
                    initialsPlaceholder
                }
                .retry(maxCount: 3)
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .apply { view in
                    if let width = width, let height = height {
                        view.frame(width: width, height: height)
                    } else if let width = width {
                        view.frame(width: width, height: width) // Square if only width provided
                    } else {
                        view
                    }
                }
        } else {
            // No image URL - show initials placeholder
            initialsPlaceholder
        }
    }
    
    private var initialsPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.chieacPrimary, .chieacSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text(getInitials(from: name))
                .font(.system(size: placeholderFontSize, weight: .bold))
                .foregroundColor(.white)
        }
        .apply { view in
            if let width = width, let height = height {
                view.frame(width: width, height: height)
            } else if let width = width {
                view.frame(width: width, height: width) // Square if only width provided
            } else {
                view
            }
        }
    }
    
    private var placeholderFontSize: CGFloat {
        let size = width ?? height ?? 60
        return size * 0.35
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map(String.init)
        return initials.prefix(2).joined().uppercased()
    }
}

// MARK: - View Extension for conditional modifiers
extension View {
    @ViewBuilder
    func apply<Content: View>(@ViewBuilder transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

// MARK: - Preview
struct CachedImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Square image with size
            CachedImageView(
                imageURL: "https://example.com/avatar.jpg",
                name: "John Doe",
                width: 60
            )
            .clipShape(Circle()) // UI layer handles circular clipping
            
            // Rectangular image
            CachedImageView(
                imageURL: "https://example.com/profile.jpg",
                name: "Jane Smith",
                width: 120,
                height: 80
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Initials only
            CachedImageView(
                imageURL: nil,
                name: "Bob Wilson",
                width: 40
            )
            .clipShape(Circle())
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
