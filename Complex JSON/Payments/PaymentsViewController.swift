//
//  PaymentsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 04/10/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import WebKit
import SwiftEventBus
import Firebase

class PaymentsViewController: UIViewController , UIGestureRecognizerDelegate , UIWebViewDelegate, WKNavigationDelegate, UIScrollViewDelegate{

   
    @IBOutlet weak var progress: UIActivityIndicatorView!
    var webview : WKWebView?
    @IBOutlet weak var coverWebView: UIView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("Im in payment view controler \(String(describing: MyVriables.currentGroup?.group_settings?.payments_url)) \n")
        Analytics.logEvent("GroupBookNowPressed", parameters: [
            "group_id": "\((MyVriables.currentGroup?.id)!)",
            "group_name": "\((MyVriables.currentGroup?.translations?[0].title)!)",
            "member_id": "\((MyVriables.currentMember?.id)!)"
            ])
     
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
    
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        webview = WKWebView(frame: .zero, configuration: configuration)
        
        //webview?.java
        //we.init(frame: .zero, configuration: configuration)
        //webview?.configuration.all
        logGroupBookNowPressedEvent(grroup_id: (MyVriables.currentGroup?.id)!, member_id: (MyVriables.currentMember?.id)!)
        webview?.scrollView.delegate = self
        progress.startAnimating()
        webview?.frame = CGRect(x: 0, y: 0, width: self.coverWebView.frame.width, height: self.coverWebView.frame.height)
        webview?.frame = self.coverWebView.bounds
        //   self.coverWebView = webview!
        // self.coverWebView.frame = (webview?.frame)!
        var urlString: String = "https://www.snapgroup.co/"
        if verifyUrl(urlString: MyVriables.currentGroup?.group_settings?.payments_url != nil ? (MyVriables.currentGroup?.group_settings?.payments_url)! : "") {
        urlString = (MyVriables.currentGroup?.group_settings?.payments_url)!
        }
        print("Url payment \(urlString)")
        
        
        //urlString = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        //webview.load(urlRequest)
        let urlss = encodedUrl(from: urlString)
        self.webview?.load(URLRequest(url: urlss!))
        self.webview?.navigationDelegate = self
        self.coverWebView.addSubview(self.webview!)
    }
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func encodedUrl(from string: String) -> URL? {
        // Remove preexisting encoding
        guard let decodedString = string.removingPercentEncoding,
            // Reencode, to revert decoding while encoding missed characters
            let percentEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                // Coding failed
                return nil
        }
        // Create URL from encoded string, or nil if failed
        return URL(string: percentEncodedString)
    }
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        if navigationType == .linkClicked
        {
            if let url_text = request.url?.absoluteURL {
                print("linkClicked:", url_text)
            }
        }
        return true;
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.frame = self.coverWebView.frame
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.frame = self.coverWebView.frame
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame = self.coverWebView.frame
        progress.hide()
        progress.isHidden = true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("yessss \(webView.tag)")
        self.progress.hide()
        self.progress.isHidden = true
        webView.frame = self.coverWebView.frame
        
        //        webView.frame.size = webView.sizeThatFits(CGSize.zero)
        
        
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation:
        WKNavigation!, withError error: Error) {
        webView.frame = self.coverWebView.bounds
        self.webview? = WKWebView(frame: self.coverWebView.bounds, configuration: WKWebViewConfiguration())
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.frame = self.coverWebView.bounds
        self.webview? = WKWebView(frame: self.coverWebView.bounds, configuration: WKWebViewConfiguration())
        
    }
    
}
