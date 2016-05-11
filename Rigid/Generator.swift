//
//  Generator.swift
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

struct Generator {
    
    enum Platform {
        case iOS
        case OSX
    }
    
    // ----------------------------------
    //  MARK: - Wrapping If Else -
    //
    private static func wrapCrossplatform(tuple: (Writable, Writable), useLineBreaks: Bool = false) -> IfElseWritable {
        return IfElseWritable(condition: "os(iOS) || os(tvOS)", pair: (ifBlock: tuple.0, elseBlock: tuple.1), useLineBreaks: useLineBreaks)
    }
    
    // ----------------------------------
    //  MARK: - Generat Imports -
    //
    static func generateImports() -> Writable {
        let conditionTrue  = Line(indent: 0, string: "import UIKit")
        let conditionFalse = Line(indent: 0, string: "import AppKit")
        
        return self.wrapCrossplatform((conditionTrue, conditionFalse), useLineBreaks: true)
    }
    
    // ------------------------------------
    //  MARK: - Generate Images -
    //
    static func generateImageExtensions() -> Writable {
        return self.wrapCrossplatform((
            self.generateImageExtension(.iOS),
            self.generateImageExtension(.OSX)
        ))
    }
    
    private static func generateImageExtension(platform: Platform) -> ExtensionWritable {
        
        var className = ""
        
        switch platform {
        case .iOS:
            className = "UIImage"
            break
            
        case .OSX:
            className = "NSImage"
            break
        }
        
        return ExtensionWritable(name: className) { () -> [Method] in
            
            var method       = Method(type: .Convenience)
            method.body      = Body(indent: 0, body: "self.init(named: name.rawValue)!")
            method.arguments = [
                Argument(label: "named", name: "name", type: "Image")
            ]
            
            return [method]
        }
    }
    
    // ------------------------------------
    //  MARK: - Generate View Controller -
    //
    static func generateViewControllerExtensions() -> Writable {
        return self.wrapCrossplatform((
            self.generateViewControllerExtension(.iOS),
            self.generateViewControllerExtension(.OSX)
        ))
    }
    
    private static func generateViewControllerExtension(platform: Platform) -> ExtensionWritable {
        
        var className      = ""
        var methodName     = ""
        
        switch platform {
        case .iOS:
            className      = "UIStoryboard"
            methodName     = "instantiateViewControllerWithIdentifier"
            break
            
        case .OSX:
            className      = "NSStoryboard"
            methodName     = "instantiateControllerWithIdentifier"
            break
        }
        
        return ExtensionWritable(name: className) { () -> [Method] in
            
            var initializer       = Method(type: .Convenience)
            initializer.body      = Body(indent: 0, body: "self.init(name: identifier.rawValue, bundle: bundle)")
            initializer.arguments = [
                Argument(name: "identifier", type: "Storyboard"),
                Argument(name: "bundle",     type: "NSBundle? = nil"),
            ]
            
            var controller        = Method(type: .Instance, name: "instantiateViewController<T>")
            controller.returnType = "T"
            controller.body       = Body(indent: 0, body: "return self.\(methodName)(viewController.rawValue) as! T")
            controller.arguments  = [
                Argument(name: "viewController", type: "ViewController"),
                Argument(name: "type",           type: "T.Type"),
            ]
            
            return [initializer, controller]
        }
    }
    
    // ----------------------------------
    //  MARK: - Generate Segue -
    //
    static func generateStoryboardSegueExtensions() -> Writable {
        return self.wrapCrossplatform((
            self.generateStoryboardSegueExtension(.iOS),
            self.generateStoryboardSegueExtension(.OSX)
        ))
    }
    
    private static func generateStoryboardSegueExtension(platform: Platform) -> ExtensionWritable {
        
        var className      = ""
        var viewController = ""
        
        switch platform {
        case .iOS:
            className      = "UIStoryboardSegue"
            viewController = "UIViewController"
            break
            
        case .OSX:
            className      = "NSStoryboardSegue"
            viewController = "NSViewController"
            break
        }
        
        return ExtensionWritable(name: className) { () -> [Method] in
            
            var body = Body(indent: 0)
            body    += Line(indent: 0, string: "if performHandler == nil {")
            body    += Line(indent: Constants.DefaultIndent, string: "self.init(identifier: segue.rawValue, source: source, destination: destination)")
            body    += Line(indent: 0, string: "} else {")
            body    += Line(indent: Constants.DefaultIndent, string: "self.init(identifier: segue.rawValue, source: source, destination: destination, performHandler: performHandler!)")
            body    += Line(indent: 0, string: "}")
            
            var initializer       = Method(type: .Convenience)
            initializer.body      = body
            initializer.arguments = [
                Argument(name: "segue",          type: "Segue"),
                Argument(name: "source",         type: viewController),
                Argument(name: "destination",    type: viewController),
                Argument(name: "performHandler", type: "(() -> ())? = nil"),
            ]
            
            body  = Body(indent: 0)
            body += Line(indent: 0, string: "if let identifier = self.identifier {")
            body += Line(indent: Constants.DefaultIndent, string: "return Segue(rawValue: identifier)!")
            body += Line(indent: 0, string: "} else {")
            body += Line(indent: Constants.DefaultIndent, string: "fatalError(\"Rigid: Could not retrieve identifier for storyboard segue. Ensure that you have assigned an identifier to this segue: \\(self)\")")
            body += Line(indent: 0, string: "}")
            
            var segue        = Method(type: .Instance, name: "segue")
            segue.body       = body
            segue.returnType = "Segue"
            
            return [initializer, segue]
        }
    }
    
    // ----------------------------------
    //  MARK: - Generate Nibs -
    //
    static func generateNibExtensions() -> Writable {
        return self.wrapCrossplatform((
            AggregatorWritable(writables: [
                self.generateNibExtension(.iOS),
                self.generateTableViewExtension(.iOS),
                self.generateCollectionViewExtension(.iOS),
            ]),
            AggregatorWritable(writables: [
                self.generateNibExtension(.OSX),
            ])
        ))
    }
    
    private static func generateNibExtension(platform: Platform) -> ExtensionWritable {
        
        var className  = ""
        var methodBody = ""
        
        switch platform {
        case .iOS:
            className  = "UINib"
            methodBody = "self.init(nibName: nib.rawValue, bundle: bundle)"
            break
            
        case .OSX:
            className  = "NSNib"
            methodBody = "self.init(nibNamed: nib.rawValue, bundle: bundle)!"
            break
        }
        
        return ExtensionWritable(name: className) { () -> [Method] in
            
            var method       = Method(type: .Convenience)
            method.body      = Body(indent: 0, body: methodBody)
            method.arguments = [
                Argument(name: "nib",    type: "Nib"),
                Argument(name: "bundle", type: "NSBundle? = nil"),
            ]
            
            return [method]
        }
    }
    
    private static func generateTableViewExtension(platform: Platform) -> ExtensionWritable {
        
        var className  = ""
        var methodBody = ""
        
        switch platform {
        case .iOS:
            className  = "UITableView"
            methodBody = "return self.dequeueReusableCellWithIdentifier(nib.rawValue, forIndexPath: indexPath) as! T"
            break
            
        case .OSX:
            className  = "NSTableView"
            methodBody = ""
            break
        }
        
        return ExtensionWritable(name: className) { () -> [Method] in
            
            var method        = Method(type: .Instance, name: "dequeueReusableCellWithNib<T>")
            method.returnType = "T"
            method.body       = Body(indent: 0, body: methodBody)
            method.arguments  = [
                Argument(name: "nib", type: "Nib"),
                Argument(label: "forIndexPath", name: "indexPath", type: "NSIndexPath"),
            ]
            
            return [method]
        }
    }
    
    private static func generateCollectionViewExtension(platform: Platform) -> ExtensionWritable {
        
        var className  = ""
        var methodBody = ""
        
        switch platform {
        case .iOS:
            className  = "UICollectionView"
            methodBody = "return self.dequeueReusableCellWithReuseIdentifier(nib.rawValue, forIndexPath: indexPath) as! T"
            break
            
        case .OSX:
            className  = "NSCollectionView"
            methodBody = ""
            break
        }
        
        return ExtensionWritable(name: className) { () -> [Method] in
            
            var method        = Method(type: .Instance, name: "dequeueReusableCellWithNib<T>")
            method.returnType = "T"
            method.body       = Body(indent: 0, body: methodBody)
            method.arguments  = [
                Argument(name: "nib", type: "Nib"),
                Argument(label: "forIndexPath", name: "indexPath", type: "NSIndexPath"),
            ]
            
            return [method]
        }
    }
    
    // ----------------------------------
    //  MARK: - Generate TableView -
    //
}

