//
//  debug.swift
//  KyoNeo
//
//  Created by Aether on 07/04/2023.
//

import SwiftUI

/**
 Logs a message to the console if the `debug` parameter is `true`.

 - Parameters:
    - message: The message to log.
    - debug: If `true`, log the message to the console.
 */
func log(_ message: String, title: String? = nil, debug: Bool = true) {
  if debug {
    var logMessage = message

    if let title = title {
      logMessage = "[\(title)] \(message)"
    }
    print("log: \(logMessage)")
  }
}
