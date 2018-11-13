//
//  Key.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/11/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation

enum Key : Int {
    case C = 0
    case C_Sharp = 1
    case D = 2
    case D_Sharp = 3
    case E = 4
    case F = 5
    case F_Sharp = 6
    case G = 7
    case G_Sharp = 8
    case A = 9
    case A_Sharp = 10
    case B = 11
    
    var description: String {
        switch self {
        case .C:
            return "C"
        case .C_Sharp:
            return "C#"
        case .D:
            return "D"
        case .D_Sharp:
            return "D#"
        case .E:
            return "E"
        case .F:
            return "F"
        case .F_Sharp:
            return "F#"
        case .G:
            return "G"
        case .G_Sharp:
            return "G#"
        case .A:
            return "A"
        case .A_Sharp:
            return "A#"
        case .B:
            return "B"
        }
    }
}

enum Mode : Int {
    case minor = 0
    case major = 1
    
    var description: String {
        return self == .minor ? "m" : ""
    }
}
