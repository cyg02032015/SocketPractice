//
//  ViewController.swift
//  ServerDemo
//
//  Created by C on 16/1/28.
//  Copyright © 2016年 YoungKook. All rights reserved.
//

import Cocoa

let WELCOME_MSG = 0
let ECHO_MSG = 1

class ViewController: NSViewController {

  @IBOutlet var textView: NSTextView!
  var listenSocket: AsyncSocket!
  var connectedSockets = NSMutableArray()
  var isRunning: Bool = false
  
  @IBOutlet weak var portField: NSTextField!
  @IBOutlet weak var startStop: NSButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    listenSocket = AsyncSocket(delegate: self)
    listenSocket.setRunLoopModes([NSRunLoopCommonModes])
    self.title = ""
    textView.editable = false
    portField.editable = false
//    let vc = ServerController().viewDidLoad()
  }
  
  @IBAction func startAndStop(sender: AnyObject) {
    if !isRunning {
      var port = portField.integerValue
      if port < 0 && port > 65535 {
        port = 0
      }
      do {
        try listenSocket.acceptOnPort(uint16(8888))
      } catch let error as NSError {
        logError(String(format: "Error starting server: %@", error.localizedDescription))
        return
      }
      logInfo(String(format: "Echo server started on port %hu", listenSocket.localHost()))
      isRunning = true
//      portField.editable = true
      startStop.title = "Stop"
    } else {
      listenSocket.disconnect()
      for (i, _) in connectedSockets.enumerate() {
        connectedSockets[i].disconnect()
      }
      logInfo("Stopped Echo server")
      isRunning = false
//      portField.enabled = true
      startStop.title = "Start"
    }
  }

  override func onSocket(sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
    connectedSockets.addObject(newSocket)
  }
  
  // MARK:  客户端连接成功
  override func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
    logInfo(String(format: "Accepted client %@:%hu", host, port))
    portField.placeholderString = String(port)
    let successMsg = "Welcome to youngkook Server"
    let data = successMsg.dataUsingEncoding(NSUTF8StringEncoding)
    sock.writeData(data, withTimeout: -1, tag: WELCOME_MSG)
  }
  
  override func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
    sock.readDataWithTimeout(-1, tag: 0)
  }
  
  // MARK: 接收数据
  override func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
//    let strData = data.subdataWithRange(NSMakeRange(0, data.length - 2))
    let recvMsg = String(data: data, encoding: NSUTF8StringEncoding)
    guard let msg = recvMsg else {
      logError("Error converting recived data into UTF-8 encode")
      return
    }
    logMessage(msg)

    var str: String!
    for (_, socket) in connectedSockets.enumerate() {
      if sock.isEqual(socket) {
        str = "我说: \(msg)"
      } else {
        str = "他说: \(msg)"
      }
    }
    
    // 回发数据
    let backData = str.dataUsingEncoding(NSUTF8StringEncoding)
    sock.writeData(backData, withTimeout: -1, tag: ECHO_MSG)
  }
  
  override func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
    logInfo(String(format: "Client willDisconnected: %@:%hu", sock.connectedHost(), sock.connectedPort()))
    if let e = err {
      print(e.localizedDescription)
    }
  }
  
  override func onSocketDidDisconnect(sock: AsyncSocket!) {
    connectedSockets.removeObject(sock)
  }
  
  func logError(msg: String) {
    print(msg)
  }
  
  func logInfo(msg: String) {
    print(msg)
  }
  
  func logMessage(msg: String) {
    print(msg)
  }
  
  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}


