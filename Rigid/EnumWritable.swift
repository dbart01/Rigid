//
//  EnumWritable.swift
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

struct EnumWritable: Writable {
    
    var indent = 0
    
    var name: String
    var objects: Set<Object>
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(objects: [Object], name: String) {
        self.init(objects: Set(objects), name: name)
    }
    
    init(objects: Set<Object>, name: String) {
        self.name    = name
        self.objects = objects
    }
    
    // ----------------------------------
    //  MARK: - Adding Objects -
    //
    mutating func append(object: Object) {
        self.objects.insert(object)
    }
    
    // ----------------------------------
    //  MARK: - Writable -
    //
    
    func content() -> String {
        
        /* -------------------------------------
        ** Sort all objects before writing them
        */
        let objects = Array(self.objects).sort {
            return $0.name < $1.name
        }
        
        /* ----------------------------------------
        ** We need to line up all the `=` signs, so
        ** we'll need the length of the longest
        ** string, that we'll use to space the rest
        ** of the strings.
        */
        let max    = self.maximumObjectLenght()
        let indent = self.indent + Constants.DefaultIndent
        
        /* -------------------------------------
        ** Write all objects into an enum string
        */
        var content = "\n"
        content += "public enum \(self.name): \(self.base()) {"
        for object in objects {
            
            var spacer = ""
            if let max = max {
                spacer = self.indent(max - object.name.characters.count)
            }
            
            content += "\n"
            content += "\(self.indent(indent))case \(object.name)\(spacer) = \"\(object.value)\""
        }
        content += "\n"
        content += "}"
        content += "\n"
        
        return content
    }
    
    // ----------------------------------
    //  MARK: - Utilities for Spacing -
    //
    private func base() -> String {
        return "String"
    }
    
    private func maximumObjectLenght() -> Int? {
        let maxObject = self.objects.maxElement { (lhs: Object, rhs: Object) -> Bool in
            return lhs.name.characters.count < rhs.name.characters.count
        }
        return maxObject?.name.characters.count
    }
}