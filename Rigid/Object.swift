//
//  Object.swift
//  Rigid
//
//  Copyright (c) 2015 Dima Bart
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.

import Foundation

struct Object: Hashable, Equatable {
    
    static let validRanges = [
        65...90,  /* uppercase range */
        97...122, /* lowercase range */
        48...57,  /* numerical range */
        95...95,  /* underscrore     */
    ]
    
    let name: String
    let value: String
    let isFile: Bool
    
    // ----------------------------------
    //  MARK: - Hashable -
    //
    var hashValue: Int {
        return self.value.hashValue
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(value: String, isFile: Bool) {
        self.isFile = isFile
        self.value  = value
        self.name   = self.dynamicType.nameFromValue(self.value)
    }
    
    init(url: NSURL, isFile: Bool) {
        let value = self.dynamicType.valueFromURL(url, isFile: isFile)
        self.init(value: value, isFile: isFile)
    }
    
    // ----------------------------------
    //  MARK: - Image Processing -
    //
    private static func valueFromURL(url: NSURL, isFile: Bool) -> String {
        if var name = url.URLByDeletingPathExtension?.lastPathComponent {
        
            /* ----------------------------------------
            ** If this is an image name, ensure that we
            ** remove all the would-be duplicates that
            ** have retina resolutions, device-specific
            ** images
            */
            if isFile {
                name = name.stringByReplacingOccurrencesOfString("@2x",     withString:"")
                name = name.stringByReplacingOccurrencesOfString("@3x",     withString:"")
                name = name.stringByReplacingOccurrencesOfString("~ipad",   withString:"")
                name = name.stringByReplacingOccurrencesOfString("~iphone", withString:"")
            }
            return name
        }
        return ""
    }
    
    private static func nameFromValue(value: String) -> String {
        
        var chars = value.cStringUsingEncoding(NSUTF8StringEncoding)!
            
        /* ----------------------------------------
        ** Ensures that all characters in the name
        ** are valid for use in a variable name.
        */
        for i in 0..<chars.count - 1 {
            let char = chars[i]
            if !self.isValidCharacter(char) {
                chars[i] = 95 /* decimal for underscore */
            }
        }
        
        var name = String(UTF8String: &chars)!
        
        /* ----------------------------------------
        ** Ensure that the first character is valid
        */
        if !self.isValidName(name) {
            name = "i\(name)"
        }
        
        return name
    }
    
    private static func isValidCharacter(character: Int8) -> Bool {
        for range in self.validRanges {
            if range.contains(Int(character)) {
                return true
            }
        }
        return false
    }
    
    private static func isValidName(name: String) -> Bool {

        for char in name.characters {
            switch char {
            case "0": fallthrough
            case "1": fallthrough
            case "2": fallthrough
            case "3": fallthrough
            case "4": fallthrough
            case "5": fallthrough
            case "6": fallthrough
            case "7": fallthrough
            case "8": fallthrough
            case "9":
                return false
                
            default:
                return true
            }
        }
        return false
    }
}

func ==(lhs: Object, rhs: Object) -> Bool {
    return lhs.value == rhs.value && lhs.isFile == rhs.isFile
}
