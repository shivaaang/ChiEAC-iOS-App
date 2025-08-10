//
//  DonationWebView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI
import WebKit

struct DonationWebView: View {
    let donationURL = "https://www.zeffy.com/en-US/fundraising/chieac-social-impact-project"
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Loading indicator
                if isLoading {
                    ProgressView("Loading donation page...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.chieacLightBackground)
                }
                
                // Web view
                WebView(
                    url: donationURL,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    showError: $showError,
                    errorMessage: $errorMessage
                )
                .opacity(isLoading ? 0 : 1)
            }
            .navigationTitle("Donate to ChiEAC")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.chieacPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Back button
                        Button(action: {
                            NotificationCenter.default.post(name: .webViewGoBack, object: nil)
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(canGoBack ? .chieacPrimary : .gray)
                        }
                        .disabled(!canGoBack)
                        
                        // Forward button
                        Button(action: {
                            NotificationCenter.default.post(name: .webViewGoForward, object: nil)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(canGoForward ? .chieacPrimary : .gray)
                        }
                        .disabled(!canGoForward)
                        
                        // Refresh button
                        Button(action: {
                            NotificationCenter.default.post(name: .webViewReload, object: nil)
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.chieacPrimary)
                        }
                    }
                }
            }
        }
        .alert("Error Loading Page", isPresented: $showError) {
            Button("Retry") {
                NotificationCenter.default.post(name: .webViewReload, object: nil)
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - WebKit Integration
struct WebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Configure web view for better user experience
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // Load the donation URL
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // Set up notification observers for toolbar actions
        NotificationCenter.default.addObserver(
            forName: .webViewGoBack,
            object: nil,
            queue: .main
        ) { _ in
            webView.goBack()
        }
        
        NotificationCenter.default.addObserver(
            forName: .webViewGoForward,
            object: nil,
            queue: .main
        ) { _ in
            webView.goForward()
        }
        
        NotificationCenter.default.addObserver(
            forName: .webViewReload,
            object: nil,
            queue: .main
        ) { _ in
            webView.reload()
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update navigation button states
        canGoBack = uiView.canGoBack
        canGoForward = uiView.canGoForward
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.showError = false
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.showError = true
            parent.errorMessage = "Unable to load the donation page. Please check your internet connection and try again."
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.showError = true
            parent.errorMessage = "Unable to connect to the donation page. Please check your internet connection and try again."
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let webViewGoBack = Notification.Name("webViewGoBack")
    static let webViewGoForward = Notification.Name("webViewGoForward")
    static let webViewReload = Notification.Name("webViewReload")
}

struct DonationWebView_Previews: PreviewProvider {
    static var previews: some View {
        DonationWebView()
    }
}