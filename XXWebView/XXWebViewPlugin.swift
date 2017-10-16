//
//  XXWebViewPlugin.swift
//  XXWebView
//
//  Created by wangxi1-ps on 2017/7/3.
//  Copyright © 2017年 x. All rights reserved.
//

import Foundation
import WebKit

public class XXWebViewPlugin: NSObject {
    public var wk:WKWebView!
    var taskId: Int!
    var data: String!
    required override public init() {
        
    }
    public func callback(value:Dictionary<String, Any>) -> Bool {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions())
            if let jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                let js = "fireTask(\(self.taskId), '\(jsonString)');"
                self.wk.evaluateJavaScript(js, completionHandler: nil)
                return true
            }
        } catch let error as NSError {
            print(error.debugDescription)
            return false
        }
        return false
    }
    public  func errorCallback(_ errorMessage: String) {
        let js = "onError(\(self.taskId), '\(errorMessage)');"
        self.wk.evaluateJavaScript(js, completionHandler: nil)
    }
}
