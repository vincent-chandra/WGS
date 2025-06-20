//
//  WebView.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable{
    var url: URL?
    @Binding var reload: Bool
    private let webview = WKWebView()

    fileprivate func loadRequest(in webView: WKWebView) {
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        loadRequest(in: webview)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        if reload {
            loadRequest(in: uiView)
            DispatchQueue.main.async {
                self.reload = false
            }
        }
    }
}
