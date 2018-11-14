//
//  UserDefaults+ValueOrDefault.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/13/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation

extension UserDefaults {
    /// Gets an enum value from user defaults and has the option of specifying a default value
    /// if none is found.
    func enumValue<EnumT>(forKey key: String, default defaultValue: EnumT) -> EnumT
        where EnumT: RawRepresentable, EnumT.RawValue == Int {
            
        if object(forKey: key) != nil {
            return EnumT(rawValue: integer(forKey: key)) ?? defaultValue
        }

        return defaultValue
    }

    /// Gets a bool value from user defaults but if one does not exist the default value is used.
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        if object(forKey: key) != nil {
            return bool(forKey: key)
        }

        return defaultValue
    }
}
