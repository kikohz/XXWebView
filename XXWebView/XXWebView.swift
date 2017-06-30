//
//  XXWebView.swift
//  TestWebview
//
//  Created by wangxi1-ps on 2017/6/29.
//  Copyright © 2017年 wangxi. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class XXWebViewController: UIViewController ,WKNavigationDelegate ,WKUIDelegate ,WKScriptMessageHandler{
    
    var webTitle:String = ""        //title
    var url:String = ""             //请求uel
    var webView:WKWebView?
    var progressView:UIProgressView?
    var errorView:UIImageView?
    
    init(url: String, defaultTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.webTitle = defaultTitle
        self.url = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = webTitle
        self.configUi()
        self.loadUrl(surl: self.url)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func creatWebView() {
        let tempWebView = WKWebView(frame: view.frame, configuration: WKWebViewConfiguration())
        tempWebView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        tempWebView.navigationDelegate = self as WKNavigationDelegate
        tempWebView.isMultipleTouchEnabled = true
        tempWebView.autoresizesSubviews = true
        tempWebView.scrollView.alwaysBounceVertical = true
        tempWebView.allowsBackForwardNavigationGestures = true
        tempWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView = tempWebView
        self.view.addSubview(self.webView!)
    }
    
    private func configUi() {
        self.creatWebView()
        //进度条
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView?.trackTintColor = UIColor(white: 1.0, alpha: 0.0)
        self.progressView?.progressTintColor = UIColor.red
        self.progressView?.frame = CGRect(x: 0, y: (self.webView?.frame.origin.y)!, width: self.view.frame.width, height: (self.progressView?.frame.size.height)!)
        self.progressView?.autoresizingMask = [.flexibleTopMargin,.flexibleWidth]
        self.progressView?.setProgress(0.5, animated: true)
        self.view.addSubview(self.progressView!)
        //错误提示图片
        self.errorView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: (self.webView?.frame.size.width)!, height: (self.webView?.frame.size.height)!))
        self.errorView?.autoresizingMask = [.flexibleWidth,.flexibleHeight];
        self.errorView?.image = UIImage.init(named: "disconnect")
        self.errorView?.isHidden = true
        self.errorView?.contentMode = .center
        self.errorView?.center = self.view.center
        self.view.addSubview(self.errorView!)
    }
    
    public func loadUrl(surl: String) {
        guard !surl.isEmpty  else {
            fatalError("URL must be a relative file URL.")
        }
        self.webView?.load(URLRequest(url: URL(string:url)!))
    }
    
    public func isLoading() ->Bool {
        return (self.webView?.isLoading)!
    }
    
    public func getTitle() -> String {
        return (self.webView?.title)!
    
    }
    
    public func evaluateJavaScriptFromString(strJs: String ,completion: ((Any) -> Swift.Void)? = nil) {
        self.webView?.evaluateJavaScript(strJs, completionHandler: { (object: Any?, error: Error?) in
            if (completion != nil) {
                completion!(object as Any)
            }
        })
    }
    // 页面加在失败处理
    func failHandle() {
        let js:String = "document.body.innerHTML"
        self.evaluateJavaScriptFromString(strJs:js) { (object: Any) in
            if object is String , !(self.webView?.isLoading)! {
                let content:String = String(describing: object)
                if content.characters.count < 10 || content == "Optional()" , !(self.webView?.isLoading)!  {
                    self.errorView?.isHidden = false
                    self.webView?.scrollView.showsHorizontalScrollIndicator = false
                }
                else {
                    self.errorView?.isHidden = true
                    self.webView?.scrollView.showsHorizontalScrollIndicator = true
                }
            }
        }
    }
    
    //MARK: Estimated Progress KVO (WKWebView)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)) {
            self.progressView?.alpha = 1.0
            let animated:Bool = (self.webView?.estimatedProgress)! > Double((self.progressView?.progress)!)
            self.progressView?.setProgress(Float((self.webView?.estimatedProgress)!), animated: animated)
            if (self.webView?.estimatedProgress)! >= Double(1.0) {
                UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
                    self.progressView?.alpha = 0.0
                }, completion: { (Bool) in
                    self.progressView?.setProgress(0.0, animated: false)
                })
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}



//MARK: WKNavigationDelegate

private typealias wkNavigationDelegate = XXWebViewController
extension wkNavigationDelegate {
    
    //MARK: WKNavigationDelegate
    /**
     *  在收到响应后，决定是否跳转
     *
     *  @param webView            实现该代理的webview
     *  @param navigationResponse 当前navigation
     *  @param decisionHandler    是否跳转block
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let app:UIApplication = UIApplication.shared
        if webView.url?.scheme == "tel" ,app.canOpenURL(webView.url!)  {
            app.canOpenURL(webView.url!)
            decisionHandler(.cancel)
            return
        }
        if webView.url?.host == "itunes.apple.com" ,app.canOpenURL(webView.url!) {
            app.canOpenURL(webView.url!)
            decisionHandler(.cancel)
            return
        }
        //过滤 _blank 标签
        if (!(navigationAction.targetFrame?.isMainFrame)!) {
            webView.evaluateJavaScript("var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}", completionHandler: nil)
        }
        decisionHandler(.allow)
        webView.scrollView.showsHorizontalScrollIndicator = true
        self.errorView?.isHidden = true
    }
    /**
     *  页面开始加载时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        
    }
    /**
     *  当内容开始返回时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    /**
     *  页面加载完成之后调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !(webView.title?.isEmpty)! {
            self.title = webView.title
        }
    }
    /**
     *  加载失败时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     *  @param error      错误
     */
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if !(webView.title?.isEmpty)! {
            self.title = webView.title
        }
        self.failHandle()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !(webView.title?.isEmpty)! {
            self.title = webView.title
        }
        self.failHandle()
    }
}
//MARK: WKUIDelegate
private typealias wkUIDelegate = XXWebViewController
extension wkUIDelegate {
    //处理alert时间
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (aa) -> Void in
            completionHandler()
        }))
        self.present(ac, animated: true, completion: nil)
    }
}
//MARK: WKScriptMessageHandler    js---Native 交互
private var jsHandlerKey: UInt8 = 0 // 我们还是需要这样的模板
typealias WJBResponseCallback = (Any?) -> Void

private typealias wkScriptMessageHandler = XXWebViewController
extension wkScriptMessageHandler {
    var jsHandler:Dictionary<String, Any> {
        get {
            return objc_getAssociatedObject(self, &jsHandlerKey) as! Dictionary
        }
        set(newValue) {
             objc_setAssociatedObject(self, &jsHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func registerHandler(handlerName:String ,handler:WJBResponseCallback?) {
        if handlerName.isEmpty || handler == nil {
            return
        }
        self.jsHandler.updateValue(handler!, forKey: handlerName)
        self.webView?.configuration.userContentController.add(self, name: handlerName)
    }
    
    //接受消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handller:WJBResponseCallback? = (self.jsHandler[message.name] as! WJBResponseCallback)
        if handller != nil {
            handller!(message.body)
        }
        print(message.name)
        print((message.body as AnyObject).description)
    }
}
