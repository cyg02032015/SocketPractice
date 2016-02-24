//
//  ServerController.swift
//  ServerDemo
//
//  Created by C on 16/1/29.
//  Copyright © 2016年 YoungKook. All rights reserved.
//

import Cocoa

class ServerController: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    testServer()
  }
  
  func echoService(client c: TCPClient) {
    print("newclient from: \(c.addr)[\(c.port)]")
    let data = c.read(1024*10)
    if let d = data {
      if let str = NSString(bytes: d, length: d.count, encoding: NSUTF8StringEncoding){
        print("raad: \(str)")
      }
    }
    c.send(data: data!)
//    c.close()
  }
  
  func testServer() {
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    dispatch_async(queue) {
      var server: TCPServer = TCPServer(addr:"127.0.0.1", port: 8080)
      var (success, msg) = server.listen()
      if success {
        while true {
          if let client = server.accept() {
            self.echoService(client: client)
          } else {
            print("accept error")
            return
          }
        }
      } else {
        print(msg)
      }
    }
  }
}
