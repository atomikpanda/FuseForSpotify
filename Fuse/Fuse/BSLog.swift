//
//  Debug.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/15/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation

/// Log manager
struct BSLog {
    static var printTimestamps: Bool = false
    static var debugPrefix: String = "💚"
    static var errorPrefix: String = "❤️"
    static var warnPrefix: String = "💛"
    
    static private var _dateFormatter: DateFormatter?
    
    static private var dateFormatter: DateFormatter {
        
        if _dateFormatter == nil {
            _dateFormatter = DateFormatter()
            _dateFormatter!.dateFormat = ": yyyy-MM-dd HH:mm:ss.SSS"
            _dateFormatter!.timeZone = .current
        }
        
        return _dateFormatter!
    }
    
    static private func prefix(_ logPrefix: String) -> String {
        return "\(logPrefix)\(printTimestamps ? dateFormatter.string(from: Date()) : ""): "
    }
    
    /// Debug Log
    static func D(_ message: String?) {
        let pref = prefix(debugPrefix)
        
        var msg = message
        if msg != nil {
            msg = msg!.replacingOccurrences(of: "\n", with: "\n\(pref)")
        }
        #if DEBUG
        print( pref + (msg ?? "(null)"))
        #endif
    }
    
    /// Error Log
    static func E(_ message: String?) {
        let pref = prefix(errorPrefix)
        
        var msg = message
        if msg != nil {
            msg = msg!.replacingOccurrences(of: "\n", with: "\n\(pref)")
        }
        #if DEBUG
        print( pref + (msg ?? "(null)"))
        #endif
    }
    
    /// Warn Log
    static func W(_ message: String?) {
        let pref = prefix(warnPrefix)
        
        var msg = message
        if msg != nil {
            msg = msg!.replacingOccurrences(of: "\n", with: "\n\(pref)")
        }
        #if DEBUG
        print( pref + (msg ?? "(null)"))
        #endif
    }
}
