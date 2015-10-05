//
//  main.swift
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

let start     = CFAbsoluteTimeGetCurrent()
let arguments = NSProcessInfo.processInfo().arguments

/* -----------------------------------------
** Ensure that we have a path to the project
** file. Otherwise we have nothing to do.
*/
guard arguments.count > 1 else {
    NSLog("Rigid is expecting a path to your project file.")
    exit(EXIT_FAILURE)
}

guard arguments.count > 2 else {
    NSLog("Rigid is expecting a destination path for the generated Rigid.swift file.")
    exit(EXIT_FAILURE)
}

let projectPath     = arguments[1]
let destinationPath = arguments[2]
let destinationURL  = NSURL(fileURLWithPath: destinationPath).URLByAppendingPathComponent(Constants.FileName)

/* ----------------------------------------
** Scan recursively the root directory of
** the project file and look for all the
** the files that we can convert to static
** strings.
*/
if let location = NSURL(fileURLWithPath: projectPath).URLByDeletingLastPathComponent {
    
    let project = Project(location: location)
    let writer  = Writer(writables: project.generateWritables())

    writer.writeToURL(destinationURL)
    
} else {
    NSLog("Unable to process provided path of project file.")
    exit(EXIT_FAILURE)
}

/* ----------------------------------------
** A quick way to see how performant the
** generation operation is.
*/
let time = String(format: "%0.2fms", (CFAbsoluteTimeGetCurrent() - start) * 1000.0)
NSLog("Processed in: \(time)")