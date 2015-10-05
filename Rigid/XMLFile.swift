//
//  XMLFile.swift
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

struct XMLFile<T: XMLIdentifiable, U: Hashable> {
    
    typealias XMLMatchHandler = (key: T, value: String) -> U
    
    let location: NSURL
    let searchables: [T : XMLSearchable]
    
    private let document: NSXMLDocument!
    private let handler: XMLMatchHandler
    
    var results: [T : Set<U>]
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init?(location: NSURL, searchables: [T : XMLSearchable], handler: XMLMatchHandler) {
        self.location    = location
        self.searchables = searchables
        self.handler     = handler
        self.results     = [T : Set<U>]()
        
        /* -------------------------------------------
        ** Populate the results with empty placeholder
        ** Set objects that will container the Object
        ** instances representing the results for each
        ** of the provided keys.
        */
        for (key, _) in searchables {
            self.results[key] = Set<U>()
        }

        /* ------------------------------------------
        ** Load and parse the XML document that we'll
        ** use to traverse the XML tree and find the
        ** results we need
        */
        if let document = try? NSXMLDocument(contentsOfURL: location, options: NSXMLDocumentTidyXML) {
            self.document = document
        } else {
            return nil
        }
        
        self.traverseNodes(startingAt: self.document)
    }
    
    // ----------------------------------
    //  MARK: - Getters -
    //
    func rootAttributeForKey(key: String) -> AnyObject? {
        if let root   = self.document.rootElement(),
        let attribute = root.attributeForName(key),
        let value     = attribute.objectValue {
        
            return value
        }
        return nil
    }
    
    func setForKey(key: T) -> Set<U> {
        return self.results[key]!
    }
    
    // ----------------------------------
    //  MARK: - Traversing XML -
    //
    mutating func traverseNodes(startingAt node: NSXMLNode) {
        if let children = node.children {
            for child in children {
                
                /* ------------------------------------------
                ** For each child, we'll need to iterate over
                ** each provided XMLSearchable to check if
                ** this node is a match. If so, we'll create
                ** an Object and insert it into the Set.
                */
                for (key, searchable) in searchables {
                    
                    /* ----------------------------------------
                    ** This check matches the element name and
                    ** attributes to each searchable, if a '*'
                    ** was provided for the element name, we'll
                    ** match any element for the specified
                    ** attribute.
                    */
                    if let element = child as? NSXMLElement, let attribute = element.attributeForName(searchable.attribute) where (searchable.name == "*" ? true : element.name == searchable.name) {
                        if let value = attribute.objectValue as? String {
                            
                            /* ----------------------------------------
                            ** We don't need to check if this key exists
                            ** becase its garanteed to have been created
                            ** during initialization.
                            */
                            self.results[key]!.insert(
                                self.handler(key: key, value: value)
                            )
                        }
                    }
                }
                
                self.traverseNodes(startingAt: child)
            }
        }
    }
}