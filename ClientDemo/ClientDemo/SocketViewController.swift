//
//  SocketViewController.swift
//  ClientDemo
//
//  Created by C on 16/1/29.
//  Copyright © 2016年 YoungKook. All rights reserved.
//

import UIKit

class SocketViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let client = TCPClient(addr:"127.0.0.1", port: 8080)
    let (succ,errmsg) = client.connect(timeout: 1)
    if succ {
      let (success, errmsg) = client.send(str: "77")
      if success {
        let data = client.read(1024*10)
        if let d = data {
          if let str = NSString(bytes: d, length: d.count, encoding: NSUTF8StringEncoding) {
            print("read: \(str)")
          }
        }
      } else {
        print(errmsg)
      }
    } else {
      print(errmsg)
    }
  }
}
