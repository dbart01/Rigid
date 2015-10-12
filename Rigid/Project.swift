//
//  Project.swift
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

struct Project {
    
    enum ItemIdentifier: XMLIdentifiable {
        case ViewController
        case TableViewCell
        case CollectionViewCell
        case ReusableViewCell
        case Segue
        case Entity
    }
    
    let location: NSURL

    private(set) var images          = Set<Object>()
    private(set) var nibs            = Set<Object>()
    private(set) var storyboards     = Set<Object>()
    private(set) var identifiers     = Set<Object>()
    private(set) var tableCells      = Set<Object>()
    private(set) var collectionCells = Set<Object>()
    private(set) var reusableCells   = Set<Object>()
    private(set) var segues          = Set<Object>()
    private(set) var entities        = Set<Object>()

    // ----------------------------------
    //  MARK: - Init -
    //
    init(location: NSURL) {
        self.location = location;
        self.scanLocation(location)
    }
    
    // ----------------------------------
    //  MARK: - Scanning Files -
    //
    private mutating func scanLocation(location: NSURL) {
        
        let fileManager = NSFileManager.defaultManager()
        let enumerator  = fileManager.enumeratorAtURL(location, includingPropertiesForKeys: nil, options: [.SkipsPackageDescendants, .SkipsHiddenFiles], errorHandler: nil)
        
        if let enumerator = enumerator {
            
            while let fileURL = enumerator.nextObject() as? NSURL {
                
                if let ext = fileURL.pathExtension {
                    switch ext {
                    case "png":  fallthrough
                    case "pdf":  fallthrough
                    case "jpg":  fallthrough
                    case "jpeg": fallthrough
                    case "tiff":
                        self.scanImage(fileURL)
                        break
                        
                    case "xib":
                        self.scanNib(fileURL)
                        break
                        
                    case "storyboard":
                        self.scanStoryboard(fileURL)
                        break
                        
                    case "xcdatamodeld":
                        self.scanLocation(fileURL)
                        break
                        
                    case "xcdatamodel":
                        self.scanDataModel(fileURL.URLByAppendingPathComponent("contents"))
                        break
                        
                    default: break
                    }
                }
            }
            
        } else {
            NSLog("Failed to enumerate directory")
            exit(EXIT_FAILURE)
        }
    }
    
    // ----------------------------------
    //  MARK: - Scanning Items -
    //
    private mutating func scanImage(location: NSURL) {
        self.images.insert(
            Object(url: location, isFile: true)
        )
    }
    
    private mutating func scanNib(location: NSURL) {
        self.nibs.insert(
            Object(url: location, isFile: true)
        )
    }
    
    private mutating func scanStoryboard(location: NSURL) {
        
        self.storyboards.insert(
            Object(url: location, isFile: true)
        )
        
        let searchables = [
            ItemIdentifier.ViewController     : XMLSearchable(name: "*",                      attribute: "storyboardIdentifier"),
            ItemIdentifier.TableViewCell      : XMLSearchable(name: "tableViewCell",          attribute: "reuseIdentifier"),
            ItemIdentifier.CollectionViewCell : XMLSearchable(name: "collectionViewCell",     attribute: "reuseIdentifier"),
            ItemIdentifier.ReusableViewCell   : XMLSearchable(name: "collectionReusableView", attribute: "reuseIdentifier"),
            ItemIdentifier.Segue              : XMLSearchable(name: "segue",                  attribute: "identifier"),
        ]
        
        let storyboard = XMLFile<ItemIdentifier, Object>(location: location, searchables: searchables) { (identifier, value) -> Object in return Object(value: value, isFile: false) }
        if let storyboard = storyboard {
            self.identifiers.unionInPlace(storyboard.setForKey(.ViewController))
            self.tableCells.unionInPlace(storyboard.setForKey(.TableViewCell))
            self.collectionCells.unionInPlace(storyboard.setForKey(.CollectionViewCell))
            self.reusableCells.unionInPlace(storyboard.setForKey(.ReusableViewCell))
            self.segues.unionInPlace(storyboard.setForKey(.Segue))
        }
    }
    
    private mutating func scanDataModel(location: NSURL) {
        let searchables = [
            ItemIdentifier.Entity : XMLSearchable(name: "entity", attribute: "name"),
        ]
        
        let dataModel = XMLFile<ItemIdentifier, Object>(location: location, searchables: searchables) { (identifier, value) -> Object in return Object(value: value, isFile: false) }
        if let dataModel = dataModel {
            self.entities.unionInPlace(dataModel.setForKey(.Entity))
        }
    }
    
    // ----------------------------------
    //  MARK: - Writables -
    //
    func generateWritables() -> [Writable] {
        
        var writables = [Writable]()
        
        self.generateCommentHeaderWritables(&writables)
        
        self.generateImportWritables(&writables)
        self.generateImageWritables(&writables)
        self.generateViewControllerWritables(&writables)
        self.generateCellWritables(&writables)
        self.generateSegueWritables(&writables)
        self.generateEntityWritables(&writables)
        self.generateNibWritables(&writables)
        
        return writables
    }
    
    // ----------------------------------
    //  MARK: - Generating Writables -
    //
    private func generateImportWritables(inout writables: [Writable]) {
        writables += Generator.generateImports()
    }
    
    private func generateCommentHeaderWritables(inout writables: [Writable]) {
        var header = CommentHeaderWritable()
        header.appendLineComment("")
        header.appendLineComment(Constants.FileName)
        header.appendLineComment("\(Constants.Description) (v\(Constants.Version))")
        header.appendLineComment("")
        
        writables += header
    }
    
    private func generateImageWritables(inout writables: [Writable]) {
        if !self.images.isEmpty {
            writables += EnumWritable(objects: self.images, name: "Image")
            writables += Generator.generateImageExtensions()
        }
    }
    
    private func generateViewControllerWritables(inout writables: [Writable]) {
        if !self.identifiers.isEmpty {
            
            writables += EnumWritable(objects: self.identifiers, name: "ViewController")
            writables += EnumWritable(objects: self.storyboards, name: "Storyboard")
            
            writables += Generator.generateViewControllerExtensions()
        }
    }
    
    private func generateCellWritables(inout writables: [Writable]) {
        if !self.tableCells.isEmpty {
            writables += EnumWritable(objects: self.tableCells, name: "TableViewCell")
        }
        
        if !self.collectionCells.isEmpty {
            writables += EnumWritable(objects: self.collectionCells, name: "CollectionViewCell")
        }
        
        if !self.reusableCells.isEmpty {
            writables += EnumWritable(objects: self.reusableCells, name: "CollectionViewReusableCell")
        }
    }
    
    private func generateSegueWritables(inout writables: [Writable]) {
        if !self.segues.isEmpty {
            
            writables += EnumWritable(objects: self.segues, name: "Segue")
            writables += Generator.generateStoryboardSegueExtensions()
        }
    }
    
    private func generateEntityWritables(inout writables: [Writable]) {
        if !self.entities.isEmpty {
            writables += EnumWritable(objects: self.entities, name: "Entity")
        }
    }
    
    private func generateNibWritables(inout writables: [Writable]) {
        if !self.nibs.isEmpty {
            writables += EnumWritable(objects: self.nibs,   name: "Nib")
            writables += Generator.generateNibExntensions()
        }
    }
}

func +=<T>(inout lhs: Array<T>, rhs: T) {
    lhs.append(rhs)
}

func +=<T>(inout lhs: Array<T>, rhs: Array<T>) {
    lhs.appendContentsOf(rhs)
}
