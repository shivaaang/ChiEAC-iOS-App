//
//  ArticlesFilterPopupCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/13/25.
//

import SwiftUI

struct ArticlesFilterPopupCard: View {
    let tags: [String]
    @Binding var selection: Set<String>
    let topOffset: CGFloat
    let dismiss: () -> Void

    @State private var tempSelection: Set<String> = []
    @State private var showDismissAlert = false

    private var hasChanges: Bool { tempSelection != selection }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { outsideTap() }

            VStack(alignment: .leading, spacing: 12) {
                header
                content
                actionRow
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.chieacCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.chieacMintGreen.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 16)
            .padding(.top, topOffset)
            .onAppear { tempSelection = selection }
        }
        .accessibilityIdentifier("articlesFilterPopup")
        .alert("Apply selected filters?", isPresented: $showDismissAlert) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Apply") { commitAndDismiss() }
        } message: {
            Text("You have unapplied changes.")
        }
    }

    private var header: some View {
        // Fix the header row height so switching Close <-> Apply doesn't cause vertical expansion
        let controlHeight: CGFloat = 32
        return HStack(alignment: .center, spacing: 12) {
            Text("Filter by Tags")
                .font(.chieacCardTitle )
                .foregroundColor(.chieacTextPrimary)
            Spacer(minLength: 8)
            Group {
                if hasChanges {
                    Button("Apply") { commitAndDismiss() }
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .frame(height: controlHeight)
                        .background(Capsule().fill(Color.chieacPrimary))
                        .foregroundColor(.white)
                        .accessibilityIdentifier("filterApplyHeader")
                } else {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.chieacPrimary)
                            .frame(width: controlHeight, height: controlHeight)
                            .background(Circle().fill(Color.chieacPrimary.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("filterClose")
                }
            }
            .frame(height: controlHeight) // enforce uniform container height
        }
        .frame(minHeight: controlHeight) // ensure row keeps height baseline
    }

    @ViewBuilder
    private var content: some View {
        if tags.isEmpty {
            Text("No tags available.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.vertical, 12)
        } else {
            let needsScroll = tags.count > 14
            Group {
                if needsScroll {
                    ScrollView(showsIndicators: false) {
                        TagFlowLayout(spacing: 8, lineSpacing: 10) {
                            tagPills
                        }
                        .padding(.top, 2)
                        .padding(.horizontal, 2)
                    }
                    .frame(maxHeight: 260)
                } else {
                    TagFlowLayout(spacing: 8, lineSpacing: 10) {
                        tagPills
                    }
                    .padding(.top, 2)
                    .padding(.horizontal, 2)
                }
            }
        }
    }

    private var tagPills: some View {
        ForEach(tags, id: \.self) { tag in
            TagTogglePill(tag: tag, isSelected: tempSelection.contains(tag)) {
                if tempSelection.contains(tag) { tempSelection.remove(tag) } else { tempSelection.insert(tag) }
            }
        }
    }

    private var actionRow: some View {
        HStack {
            if tempSelection.isEmpty {
                Text("Clear All")
                    .font(.callout.weight(.semibold))
                    .opacity(0)
            } else {
                Button("Clear All") { tempSelection.removeAll() }
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.red)
                    .accessibilityIdentifier("filterClearAll")
            }
            Spacer()
        }
        .padding(.top, 2)
    }

    private func outsideTap() {
        if hasChanges { showDismissAlert = true } else { dismiss() }
    }

    private func commitAndDismiss() {
        selection = tempSelection
        dismiss()
    }
}

// Reusable tag pill
private struct TagTogglePill: View {
    let tag: String
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Text(tag)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .foregroundColor(.chieacTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isSelected ? Color.chieacPrimary.opacity(0.22) : Color(hex: "#e1e4e8"))
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color.chieacPrimary : Color.chieacPrimary.opacity(0.12), lineWidth: isSelected ? 1 : 0.75)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("filterTag_\(tag)")
    }
}

// Flow layout for wrapping tag pills
private struct TagFlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? UIScreen.main.bounds.width - 60
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth { // wrap
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth { // wrap
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            sub.place(at: CGPoint(x: bounds.minX + currentX, y: bounds.minY + currentY), proposal: ProposedViewSize(width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

#if DEBUG
struct ArticlesFilterPopupCard_Previews: PreviewProvider {
    @State static var sel: Set<String> = ["Education", "Health"]
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            ArticlesFilterPopupCard(
                tags: ["Education", "Health", "Nutrition", "Housing", "Advocacy", "Community", "Wellness"],
                selection: $sel,
                topOffset: 120,
                dismiss: {}
            )
        }
    }
}
#endif
