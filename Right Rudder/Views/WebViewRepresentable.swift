//
//  WebViewRepresentable.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI
import WebKit

// MARK: - WebViewRepresentable

struct WebViewRepresentable: UIViewRepresentable {
  // MARK: - Properties

  let htmlContent: String

  // MARK: - UIViewRepresentable

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    webView.loadHTMLString(htmlContent, baseURL: nil)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      // Web view finished loading
    }
  }
}

