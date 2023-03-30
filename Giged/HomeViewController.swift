//
//  HomeViewController.swift
//  Giged
//
//  Created by Tarun Mahajan on 31/08/22.
//

import UIKit
import WebKit
import SafariServices
import Firebase
class HomeViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var splashView: UIView!
    private var observation: NSKeyValueObservation? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadWebView()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // add observer to update estimated progress value
        observation = webView.observe(\.estimatedProgress, options: [.new]) { _, _ in
            self.progressView.progress = Float(self.webView.estimatedProgress)
            if self.progressView.progress >= 1.0 { // delaying so that user can see progress view reach 100%
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    self.progressView.isHidden = true
                })
            } else {
                self.progressView.isHidden = false
            }
           }
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            //            urlLink = AppDelegate.shared.urlLink
            //            AppDelegate.shared.urlLink = ""
        }
        override func viewDidAppear(_ animated: Bool) {
            super .viewDidAppear(animated)
            NoNetworkManager.networkShared().enableLackOfNetworkTakeover()
        }
        @objc func reloadWebView() {
            splashView.isHidden = false
            let url = URL(string: "")! //Add your website link here example https://wwww.example.com
            webView.uiDelegate = self
            webView.navigationDelegate = self
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
    extension HomeViewController: WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            splashView.isHidden = true
            self.webView.evaluateJavaScript(
                "document.title"
            ) { (result, error) -> Void in
                if let title = (result as? String) {
                    if title.contains("-") {
                        self.navigationItem.title = title.components(separatedBy: "-").first
                    } else {
                        self.navigationItem.title = title.components(separatedBy: " | ").first
                    }
                }
            }
            UIView.animate(withDuration: 0.33,
                           animations: {
                self.progressView.alpha = 0.0
            }, completion: {[weak self] isFinished in
                // Update `isHidden` flag accordingly:
                //  - set to `true` in case animation was completly finished.
                //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                self?.progressView.isHidden = isFinished
//                if self?.urlLink != "" {
//                    self?.openLink()
//                }
            })
            // get all cookies
            webView.getCookies() { data in
                print("=========================================")
                print(data)
                if let jwtToken = data["mobileJWT"] {
                   
                    self.getFCMToken(jwtToken: jwtToken as! String)
                }
            }
        }
        func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            if progressView.isHidden {
                // Make sure our animation is visible.
                progressView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.33,
                           animations: {
                self.progressView.alpha = 1.0
            })
        }
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
        }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url?.absoluteString else {
                return
            }
            if url.contains("about:blank") {
                decisionHandler(.cancel)
                return
            }
//            if let host = navigationAction.request.url?.host, (host == HOST_URL || host == HOST_URL1)   {
//                if url.contains("reset")  {
//                    self.navigationController?.setNavigationBarHidden(false, animated: true)
//                } else if url.contains("privacy-policy") {
//                    let config = SFSafariViewController.Configuration()
//                    config.entersReaderIfAvailable = false
//                    let vc = SFSafariViewController(url: navigationAction.request.url!, configuration: config)
//                    present(vc, animated: true)
//                    decisionHandler(.cancel)
//                    return
//                }
//            }
//            else if  let host = navigationAction.request.url?.host, (host.contains("youtube.com") || host.contains("vimeo.com") || host.contains("app.hubspot")) {
//                decisionHandler(.allow)
//                return
//            }
//            else {
//                if let urlToOpen = URL(string: url) {
//                    if url.contains("mailto:") {
//                        UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
//                        decisionHandler(.cancel)
//                        return
//                    }
//                    let config = SFSafariViewController.Configuration()
//                    config.entersReaderIfAvailable = false
//                    let vc = SFSafariViewController(url: urlToOpen, configuration: config)
//                    present(vc, animated: true)
//                }
//                decisionHandler(.cancel)
//                return
//            }
            decisionHandler(.allow)
        }
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                completionHandler()
            }))
            
            present(alertController, animated: true, completion: nil)
        }
        
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            
//            if message == "Allow push notifications from this device" {
//                self.askForNotificationPermission(askForPermission: true)
//                completionHandler(false)
//            } else {
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    completionHandler(true)
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                    completionHandler(false)
                }))
                
                present(alertController, animated: true, completion: nil)
           // }
        }
        
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            
            let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.text = defaultText
            }
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if let text = alertController.textFields?.first?.text {
                    completionHandler(text)
                } else {
                    completionHandler(defaultText)
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                completionHandler(nil)
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    }


extension WKWebView {
    
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
    func setCookie(deviceToken: String, webViewObject: WKWebView, domainName: String) {
        let cookie = HTTPCookie(properties: [
            .domain: domainName,
            .path: "/",
            .name: "device_token",
            .value: deviceToken,
            .secure: "False"
//            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!

        webViewObject.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)

    }
    func getCookies(for domain: String? = nil, completion: @escaping ([String : AnyObject])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.value as AnyObject
                    }
                } else {
                    //cookieDict[cookie.name] = cookie.properties as AnyObject?
                    if cookie.name == "mobileJWT" {
                        cookieDict[cookie.name] = cookie.value as AnyObject
                    }
                }
            }
            completion(cookieDict)
        }
    }
}

extension HomeViewController {
    func getFCMToken(jwtToken: String) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.sendDeviceTokenToServer(fcmToken: token, jwtToken: jwtToken)
            }
        }
        
    }
    @objc func sendDeviceTokenToServer(fcmToken: String, jwtToken: String) {
        
        
        let headers = [
          "content-type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache",
          "postman-token": "3679ea3d-9d4b-5836-29ff-bae10851b57d"
        ]

        let postData = NSMutableData(data: "deviceJWT=\(jwtToken)".data(using: String.Encoding.utf8)!)
        postData.append("&fcmToken=\(fcmToken)".data(using: String.Encoding.utf8)!)

        let request = NSMutableURLRequest(url: NSURL(string: "https://app.giged.es/firebasetoken/ios/")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
              print(error ?? "")
          } else {
              if let data = data {
                  do {
                      let json = try JSONSerialization.jsonObject(with: data, options: [])
                      print(json)
                      guard let jsonObject = json as? [String: Any], let statusCode = jsonObject["status"] as? Int, statusCode == 200 else {
                          return
                      }

                  } catch {
                      print(error)
                  }
              }
          }
        })

        dataTask.resume()
        
    }
}
