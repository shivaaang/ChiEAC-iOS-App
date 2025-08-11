//
//  ArticleWebView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/10/25.
//

import SwiftUI
import WebKit

struct ArticleWebView: View {
    let urlString: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.chieacLightBackground)
                }
                ArticleWebRepresentable(
                    urlString: urlString,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    showError: $showError,
                    errorMessage: $errorMessage
                )
                .opacity(isLoading ? 0 : 1)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.chieacPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button { NotificationCenter.default.post(name: .webViewGoBack, object: nil) } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(canGoBack ? .chieacPrimary : .gray)
                        }.disabled(!canGoBack)
                        Button { NotificationCenter.default.post(name: .webViewGoForward, object: nil) } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(canGoForward ? .chieacPrimary : .gray)
                        }.disabled(!canGoForward)
                        Button { NotificationCenter.default.post(name: .webViewReload, object: nil) } label: {
                            Image(systemName: "arrow.clockwise").foregroundColor(.chieacPrimary)
                        }
                    }
                }
            }
        }
        .alert("Error Loading Page", isPresented: $showError) {
            Button("Retry") { NotificationCenter.default.post(name: .webViewReload, object: nil) }
            Button("Cancel", role: .cancel) { dismiss() }
        } message: { Text(errorMessage) }
    }
}

private struct ArticleWebRepresentable: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url = URL(string: urlString) { webView.load(URLRequest(url: url)) }
        NotificationCenter.default.addObserver(forName: .webViewGoBack, object: nil, queue: .main) { _ in webView.goBack() }
        NotificationCenter.default.addObserver(forName: .webViewGoForward, object: nil, queue: .main) { _ in webView.goForward() }
        NotificationCenter.default.addObserver(forName: .webViewReload, object: nil, queue: .main) { _ in webView.reload() }
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        canGoBack = uiView.canGoBack
        canGoForward = uiView.canGoForward
    }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ArticleWebRepresentable
        init(_ parent: ArticleWebRepresentable) { self.parent = parent }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true; parent.showError = false
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false; parent.showError = true
            parent.errorMessage = "Unable to load the page. Please try again."
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false; parent.showError = true
            parent.errorMessage = "Unable to connect. Please check your internet connection and try again."
        }
    }
}
