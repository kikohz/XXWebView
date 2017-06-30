//
//  ViewController.swift
//  XXWebView
//
//  Created by wangxi1-ps on 2017/6/30.
//  Copyright © 2017年 x. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let webview = XXWebViewController.init(url: "http://www.apple.com.cn", defaultTitle: "apple")
        self.present(webview, animated: true, completion: nil)
    }

}

