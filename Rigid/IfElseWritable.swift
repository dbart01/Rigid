//
//  IfElseWritable.swift
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

struct IfElseWritable: Writable {
    
    typealias IfElsePair = (ifBlock: Writable, elseBlock: Writable)
    
    var indent: Int = 0
    let condition: String
    let pair: IfElsePair
    let useLineBreaks: Bool
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(condition: String, pair: IfElsePair, useLineBreaks: Bool = false) {
        self.condition     = condition
        self.pair          = pair
        self.useLineBreaks = useLineBreaks
    }
    
    // ----------------------------------
    //  MARK: - Writable -
    //
    func content() -> String {
        
        var content = "\n"
        content    += "#if \(self.condition)"
        if self.useLineBreaks {
            content += "\n"
        }
        
        content    += pair.ifBlock.content()
        content    += "#else"
        if self.useLineBreaks {
            content += "\n"
        }
        
        content    += pair.elseBlock.content()
        content    += "#endif\n"
        
        return content
    }
}