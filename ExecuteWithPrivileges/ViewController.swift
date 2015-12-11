//
//  ViewController.swift
//  ExecuteWithPrivileges
//
//  Created by Duff Neubauer on 12/10/15.
//  Copyright © 2015 Duff Neubauer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  // MARK: - IBOutlet
  @IBOutlet var console: NSTextView!
  
  // MARK: - IBActions
  @IBAction func userDidEnterCommand(sender: NSTextField) {
    guard sender.stringValue != "" else { return }
    
    let commandLine = sender.stringValue.componentsSeparatedByCharactersInSet(.whitespaceCharacterSet())
    let execAsAdmin = commandLine.first! == "sudo"
    let commandIdx  = execAsAdmin ? 1 : 0
    let command     = commandLine.count > commandIdx ? commandLine[commandIdx] : ""
    let args        = commandLine.count > (commandIdx + 1) ? Array<String>(commandLine[commandIdx+1 ..< commandLine.count]) : []
    
    if execAsAdmin {
      self.printToConsole("Unable to execute commands as admin.")
    } else {
      self.executeCommand(command, withArguments: args)
    }
  }
  
  // MARK: - Executing Commands
  
  private func executeCommand(command: String, withArguments: [String]) {
    self.clearConsole()
    
    var launchPath  = self.outputFromTask(launchPath: "/usr/bin/which", withArguments: [command])
    launchPath      = launchPath.stringByReplacingOccurrencesOfString("\n", withString: "")
    
    let arguments   = withArguments.map({ ($0 as NSString).stringByExpandingTildeInPath })
    
    let output      = self.outputFromTask(launchPath: launchPath, withArguments: arguments)
    
    self.printToConsole(output)
  }
  
  private func outputFromTask(launchPath launchPath: String, withArguments arguments: [String]) -> String {
    
    let task = NSTask()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let outPipe = NSPipe()
    let errPipe = NSPipe()
    let outFile = outPipe.fileHandleForReading
    let errFile = errPipe.fileHandleForReading
    
    task.standardOutput = outPipe
    task.standardError  = errPipe
    
    
    task.launch()
    task.waitUntilExit()
    
    let outData = outFile.readDataToEndOfFile()
    let output  = NSString(data: outData, encoding: NSUTF8StringEncoding) as! String
    
    let errData = errFile.readDataToEndOfFile()
    let error   = NSString(data: errData, encoding: NSUTF8StringEncoding) as! String
    
    return output != "" ? output : error
  }
  
  // MARK: - Printing to console
  
  private func printToConsole(output: String) {
    let attrString = NSAttributedString(string: "\(output)\n")
    self.console.textStorage?.appendAttributedString(attrString)
  }
  
  private func clearConsole() {
    self.console.string = ""
  }
}

