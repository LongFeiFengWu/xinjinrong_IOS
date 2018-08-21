//
//  ViewController.swift
//  新金融参考
//
//  Created by 薛文浩 on 2018/6/11.
//  Copyright © 2018年 异彩传媒. All rights reserved.
//


import UIKit
import WebKit

class ViewController: UIViewController,WKUIDelegate, WKNavigationDelegate,UIWebViewDelegate, FloatDelegate{
    
    var webView: WKWebView!
    var open_url:String = "http://jinrongcankao.net"
    var refreshControl = UIRefreshControl()
    
    var index = 0
    var urlArr = NSArray()
    var titleArr = NSArray()
    
    var popMenu:SwiftPopMenu!
    let KSCREEN_WIDTH:CGFloat = UIScreen.main.bounds.size.width
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWKwebView()
        self.navigationController?.navigationBar.barTintColor  = UIColor.white
        
        let frame = CGRect.init(x: 3, y: 100, width: 45, height: 45)
        let allbutton = AllFloatButton.init(frame: frame)
        allbutton.delegate = self
        allbutton.backgroundColor = UIColor.black
        allbutton.setBackgroundImage(UIImage(named:"menu.png"), for: UIControlState.normal)
        self.view.addSubview(allbutton)
        
    }
    
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(1), width: UIScreen.main.bounds.width, height: 3))
        self.progressView.tintColor = UIColor.blue     // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()
    
    func singleClick() {
         self.showMenu()
    }
    
    func repeatClick() {
        // print("单击22")
       
    }
    
    func doShare(){
        UMSocialUIManager.showShareMenuViewInWindow { (platformType, shreMenuView) in
            let messageObject:UMSocialMessageObject = UMSocialMessageObject.init()
            
            //分享网页
            let shareObject:UMShareWebpageObject = UMShareWebpageObject.init()
            shareObject.title = self.webView.title
            shareObject.descr = self.webView.title
            shareObject.thumbImage = UIImage.init(named: "logoN")
            shareObject.webpageUrl = self.webView.url?.absoluteString
            messageObject.shareObject = shareObject;
            
            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self, completion: { (shareResponse, error) -> Void in
                if error != nil {
                    // print("Share Fail with error")
                }else{
                    // print("Share succeed")
                }
            })
        }
    }
    
    func showMenu() {
        //frame 为整个popview相对整个屏幕的位置  箭头距离右边位置，默认15
        popMenu =  SwiftPopMenu(frame: CGRect(x: KSCREEN_WIDTH - 100, y: 20, width: 100, height: 160), arrowMargin: 15)

        popMenu.popData = [(icon:"share",title:"分享"),
                           (icon:"back",title:"返回"),
                           (icon:"refresh",title:"刷新")
        ]
        //点击菜单
        popMenu.didSelectMenuBlock = { [weak self](index:Int)->Void in
            self?.popMenu.dismiss()
            if index == 0 {
                self?.doShare()
            }
            if index == 1 {
                if self?.webView.canGoBack == true{
                    self?.webView.goBack()
                }
            }
            if index == 2 {
                self?.refresh()
            }
            
        }
        popMenu.show()
    }
    
    
    // 创建webview
    func setUpWKwebView() {
        let webConfiguration = WKWebViewConfiguration()
        let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        let url = URL(string: open_url);
        let request = URLRequest(url: url!);
        webView.load(request)
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        refreshControl.addTarget(self, action:#selector(ViewController.refresh), for: .valueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string:"刷新中... ...")
        self.webView.scrollView.addSubview(refreshControl)
    }
    
 
    
    @objc func refresh(){
        //刷新页面
        self.webView.reload()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //  加载进度条
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float((self.webView?.estimatedProgress) ?? 0), animated: true)
            if (self.webView?.estimatedProgress ?? 0.0)  >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //加载完成后停止刷新
         refreshControl.endRefreshing()
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        decisionHandler(.allow)
    }
    
    deinit {
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView?.uiDelegate = nil
        self.webView?.navigationDelegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


