//
//  ViewController.swift
//  ClientDemo
//
//  Created by C on 16/1/28.
//  Copyright © 2016年 YoungKook. All rights reserved.
//

import UIKit

let CONNECTED = 0
let CONNECT_SUC = 1
let CONNECT_FIL = 2

let HOST_IP = "192.168.168.61"
let PORT: UInt16 = 8888
class ViewController: UIViewController {
  
  typealias ActionHandler = UIAlertAction->Void
  @IBOutlet weak var adressTF: UITextField!
  @IBOutlet weak var portTF: UITextField!
  @IBOutlet weak var textView: UITextView!
  
  var content: String!
  var clientSocket: AsyncSocket!
  var inputMsg: String!
  var outputMsg: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    let vc = SocketViewController().viewDidLoad()
    let state = connectServer(HOST_IP, port: PORT)
    print("Connect server state: \(state)")
  }
  
  func alert(title: String, message: String, type: UIAlertControllerStyle, actionClousure: ActionHandler) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
    let sure = UIAlertAction(title: "sure", style: .Default) { alertAction in
      actionClousure(alertAction)
    }
    let cancel = UIAlertAction(title: "cancel", style: .Destructive, handler: nil)
    alertController.addAction(cancel)
    alertController.addAction(sure)
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func connectServer(hostIP: String, port: UInt16) -> Int {
    if clientSocket == nil {
      clientSocket = AsyncSocket(delegate: self)
      do {
        try clientSocket.connectToHost(hostIP, onPort: port)
        return CONNECT_SUC
      } catch let error as NSError {
        print(error.localizedDescription)
        alert("Error", message: " Connect server Error\nWould u want reconnect?", type: .Alert, actionClousure: { action in
          // reconnect
        })
        return CONNECT_FIL
      }
    } else {
      return CONNECTED
    }
  }
  
  override func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
    sock.readDataWithTimeout(-1, tag: 0)
    print("didConnectTohost: \(host) port: \(port)")
  }
  
  override func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
    print("Read: \(String(data: data, encoding: NSUTF8StringEncoding))")
  }
  
  override func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
    print("WriteData")
    sock.readDataWithTimeout(-1, tag: 0)
  }
  func showMessage(msg: String) {
    
  }
  
  @IBAction func send(sender: AnyObject) {
    clientSocket.writeData("hello".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
  }

  @IBAction func connect(sender: AnyObject) {
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

