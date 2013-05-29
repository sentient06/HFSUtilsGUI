//
//  CreateImageWindowController.h
//  HFSUtilsGUI
//
//  Created by Giancarlo Mariot on 28/05/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
@class ImageUtility;

/*!
 * @class       CreateImageWindowController:
 * @abstract    Responsible for displaying the create image window while
 *              generating the required file.
 */
@interface CreateImageWindowController : NSWindowController {
    IBOutlet NSProgressIndicator * currentProgressBar;
}
//------------------------------------------------------------------------------
// Properties

@property (retain) ImageUtility * imageUtility;
@property (copy) NSString * currentStep, * actionTitle;
@property int currentProgress;

//------------------------------------------------------------------------------
// Interface actions

- (id)initWithWindowNibName:(NSString *)windowNibName
                   withPath:(NSURL*)filePath
                    andType:(NSString*)volumeType
                   andLabel:(NSString*)volumeLabel
                    andSize:(NSNumber*)volumeSize
                     inUnit:(int)sizeUnit
               onFileSystem:(NSString*)fileSystem;

@end
