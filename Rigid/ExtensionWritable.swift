//
//  ExtensionWritable.swift
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

struct ExtensionWritable: Writable {
    
    var indent: Int = 0
    
    var name: String
    var methods: [Method]
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, methods: () -> [Method]) {
        self.name    = name
        self.methods = methods()
    }
    
    // ----------------------------------
    //  MARK: - Adding Objects -
    //
    mutating func append(method: Method) {
        self.methods.append(method)
    }
    
    // ----------------------------------
    //  MARK: - Writable -
    //
    func content() -> String {
        
        /* -------------------------------------
        ** Write all objects into an enum string
        */
        var content = "\n"
        content += "extension \(self.name) {"
        for var method in self.methods {

            method.indent = Constants.DefaultIndent
            
            content += "\n\n"
            content += method.content()
        }
        content += "\n"
        content += "}"
        content += "\n"
        
        return content
    }
}