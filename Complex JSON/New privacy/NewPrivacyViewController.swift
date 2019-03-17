//
//  NewPrivacyViewController.swift
//  Snapgroup
//
//  Created by snapmac on 03/01/2019.
//  Copyright © 2019 snapmac. All rights reserved.
//

import UIKit
import WebKit
import SwiftEventBus

class NewPrivacyViewController: UIViewController , UIGestureRecognizerDelegate , UIWebViewDelegate, WKNavigationDelegate, UIScrollViewDelegate{

    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    var webview : WKWebView? = WKWebView()
    @IBOutlet weak var coverWebView: UIView!
    @IBOutlet weak var overview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // webview.frame =
        progress.startAnimating()
        //webview.frame  = self.overview.frame
        webview?.scrollView.delegate = self
        webview?.frame = CGRect(x: 0, y: 0, width: self.coverWebView.frame.width, height: self.coverWebView.frame.height)
        webview?.frame = self.coverWebView.bounds
        //   self.coverWebView = webview!
        // self.coverWebView.frame = (webview?.frame)!
        
        var urlString: String = "https://www.snapgroup.co/privacy-policy/"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        //webview.load(urlRequest)
        self.webview?.load(URLRequest(url: NSURL(string:
            urlString)! as URL))
        self.webview?.navigationDelegate = self
        
        
        // self.webview?.allowsBackForwardNavigationGestures = true
        // self.webview?.scrollView.bounces = true
        //  self.webview?.sizeToFit()
        self.coverWebView.addSubview(self.webview!)
    }
    @IBAction func onDismiss(_ sender: Any) {
        MyVriables.kindRegstir = ""
        setCheckTrue(type: "terms_decline", groupID: -1)
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var dismissLabel: UILabel!
    
    
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
        progress.show()
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
        // buttonScoll.isHidden = false
        webView.frame = self.coverWebView.frame
        
        //        webView.frame.size = webView.sizeThatFits(CGSize.zero)
        
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if (self.webview?.scrollView.contentOffset.y)! >= ((self.webview?.scrollView.contentSize.height)! - (self.webview?.scrollView.frame.size.height)!) {

            
            //you reached end of the table
        }
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
