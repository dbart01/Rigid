//
//  Method.swift
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

struct Method: Writable {
    
    enum Type: String {
        case Static      = "static func"
        case Instance    = "func"
        case Initializer = "init"
        case Convenience = "convenience init"
    }
    
    var indent: Int = 0
    
    var type: Type
    var name: String?
    var arguments: [Argument]?
    var returnType: String?
    var body: Body?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(type: Type, name: String? = nil, returnType: String? = nil, args: [Argument]? = nil, body: Body? = nil) {
        self.type       = type
        self.name       = name
        self.arguments  = args
        self.returnType = returnType
        self.body       = body
    }
    
    // ----------------------------------
    //  MARK: - Adding Arguments -
    //
    mutating func addArgument(argument: Argument) {
        if self.arguments == nil {
            self.arguments = [Argument]()
        }
        self.arguments?.append(argument)
    }
    
    // ----------------------------------
    //  MARK: - Writable -
    //
    func content() -> String {
        var content = ""

        content += self.indent()
        
        /* -------------------------------------------
        ** Different types of methods will be composed
        ** differently. We'll switch through the types
        ** here and append the appropriate statement.
        */
        switch self.type {
        case .Static: fallthrough
        case .Instance:
            content += "\(self.type.rawValue) \(self.name!)"
            break
            
        case .Convenience: fallthrough
        case .Initializer:
            content += "\(self.type.rawValue)"
            break
        }
        
        /* ----------------------------------------
        ** If we have arguments, iterate and append
        ** them in order. If not, just skip over.
        */
        content += "("
        if let arguments = self.arguments {
            for (i, arg) in arguments.enumerate() {
                if i > 0 {
                    content += ", "
                }
                content += arg.content()
            }
        }
        content += ")"
        
        /* ----------------------------------------
        ** Append the return type only if it was
        ** provided. Otherwise, leave it blank.
        */
        if let returnType = self.returnType {
            content += " -> \(returnType)"
        }
        
        /* -----------------------------------------
        ** If the body was provided, append it. Else
        ** it may be a simple declaration without a
        ** function body, so leave it blank
        */
        if var body = self.body {
            
            /* -------------------------------------------
            ** The body of the method needs to be indented
            ** the same as the method declaration, plus a
            ** standard distance within the curly braces.
            */
            body.indent = self.indent + Constants.DefaultIndent
            
            content   += " {\n"
            content   += body.content()
            content   += self.indent()
            content   += "}"
        }
        
        return content
    }
}