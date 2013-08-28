//
//  AppDelegate.h
//  HFSUtilsGUI
//
//  Created by Giancarlo Mariot on 17/05/2013.
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
// Note on version numbering:
//
// There are 5 elements in the version number: 1.2.3s 004 where:
//  1 ---> major version
//  2 ---> minor version
//  3 ---> revision (bug fixing)
//  s ---> stage: alpha, beta or final (omitted)
//  004 -> build
//  
// So, for example:
//
//  1.0.0a   is an alpha release, not public
//  1.0.0b   is the first beta release, public
//  1.0.0    is the final release based on 1.0.0b
//  1.0.0a16 is the an alpha past 16 stages to fix bugs
//  1.0.1b   is the beta bug-fixed version of the previous one
//  1.1.0b   is a beta post-final release v1 with a major fix or new expected / planned feature
//  1.1.0    is a final release based on v1, but with revisions
//  2.0.0b   is the beta for a next version with new features
//  etc.
//------------------------------------------------------------------------------
// Updates are on:
// http://hfsutilsgui.mariot.me.uk
//------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class ImageFilesOutlineViewController;

/*!
 * @class       AppDelegate:
 * @abstract    Responsible for all the OS interaction, for short.
 * @discussion  This is the main class of this project. Maybe in the future I
 *              will transfer the main functionality of the data handling to a
 *              new class. But lets keep it simple until we need that.
 */
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    dispatch_queue_t queue;
    // Grand Central Dispatch queue
    
    // Views - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    IBOutlet NSView   * newImageAccessory;
    
    // Acessory's items  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSPopUpButton * imageType;
    IBOutlet NSTextField   * imageLabel;
    IBOutlet NSPopUpButton * imageSize;
    IBOutlet NSPopUpButton * imageFsys;
    IBOutlet NSMenuItem    * imageSizeCustom;
    
    ImageFilesOutlineViewController * availableImages;
    
}

//------------------------------------------------------------------------------
// Application's properties.

@property (assign) IBOutlet NSWindow * window;

//------------------------------------------------------------------------------
// Properties

@property (copy) NSURL       * pathToFile;
@property (copy) NSArray     * allowedTypesOfImage
                           , * sizesListForImage
                           , * allowedFormatsOfImage;
@property (copy) NSSavePanel * savePanel;

//------------------------------------------------------------------------------
// Interface actions

- (IBAction)saveNewImage:(id)sender;
- (IBAction)quitApplication:(id)sender;

//------------------------------------------------------------------------------
// Trigger to save image

- (void) saveImageToPath:(NSURL*)filePath
                withType:(NSString*)volumeType
                andLabel:(NSString*)volumeLabel
                 andSize:(NSNumber*)volumeSize
                  inUnit:(int)sizeUnit
            onFileSystem:(NSString*)fileSystem;

// Method to list currently mounted disks
- (void) getAllMountedDiskImages;

@end
