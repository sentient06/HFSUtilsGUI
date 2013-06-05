//
//  CreateImageWindowController.m
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

#import "CreateImageWindowController.h"
#import "ImageUtility.h"

//------------------------------------------------------------------------------

@implementation CreateImageWindowController

//------------------------------------------------------------------------------
// Synthesisers

@synthesize imageUtility; //ImageUtility
@synthesize currentStep, actionTitle; //NSString
@synthesize currentProgress; //int
@synthesize currentProgressBar = _currentProgressBar;

//------------------------------------------------------------------------------
// Methods

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [_currentProgressBar stopAnimation:self];
    [imageUtility removeObserver:self forKeyPath:@"currentActionProgress"];
    [imageUtility removeObserver:self forKeyPath:@"currentActionDescription"];
    [imageUtility release];
    [super dealloc];

}

// Init methods

#pragma mark – Init

/*!
 * @method      initWithWindow
 * @abstract    Init method.
 */
- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/*!
 * @method      initWithWindowNibName:
 *              withPath:
 *              andType:
 *              andLabel:
 *              andSize:
 *              inUnit:
 *              onFileSystem:
 * @abstract    Init method that sets all necessary ImageUtility's variables.
 */
- (id)initWithWindowNibName:(NSString *)windowNibName
                   withPath:(NSURL*)filePath
                    andType:(NSString*)volumeType
                   andLabel:(NSString*)volumeLabel
                    andSize:(NSNumber*)volumeSize
                     inUnit:(int)sizeUnit
               onFileSystem:(NSString*)fileSystem {
    
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        // Image Utility object:
        
         imageUtility = [[ImageUtility alloc] init];
        [imageUtility setPathToFile: [
            NSString stringWithFormat:@"%@%@",
            [filePath path], volumeType
        ]];
        [imageUtility setVolumeLabel:volumeLabel];
        [imageUtility setVolumeSize:[volumeSize intValue]];
        [imageUtility setVolumeSizeUnity:sizeUnit];
        [imageUtility setFileSystem:fileSystem];        
        
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        // Observers to update the interface:
        
        [imageUtility
            addObserver:self
             forKeyPath:@"currentActionProgress"
                options:NSKeyValueObservingOptionNew
                context:nil
        ];
        
        [imageUtility
            addObserver:self
             forKeyPath:@"currentActionDescription"
                options:NSKeyValueObservingOptionNew
                context:nil
        ];
        
        self.currentProgress = 0;
        self.currentStep = @"Initialising...";
        self.actionTitle = [NSString stringWithFormat: @"Creating %@ image \"%@\"", fileSystem, volumeLabel];
        
    }
    
    return self;
    
}

/*!
 * @method      observeValueForKeyPath:
 *              ofObject:
 *              change:
 *              context:
 * @abstract    Observer method.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"currentActionProgress"]) {
//        self.currentProgress = [[object valueForKeyPath:keyPath] intValue] * 25;
        NSLog(@"- - - %@", [object valueForKeyPath:@"currentActionProgress"]);
        [_currentProgressBar setDoubleValue:
            [[object valueForKeyPath:keyPath] doubleValue]
        ];

//        while ([_currentProgressBar doubleValue] < [[object valueForKeyPath:keyPath] doubleValue]) {
//            [_currentProgressBar incrementBy: 0.5];
//            [_currentProgressBar display];
////            [NSThread sleepForTimeInterval:0.5f];
//        }
        
        // This damn progress bar doesn't work properly. Research.
    }

    if ([keyPath isEqualToString:@"currentActionDescription"]){
        self.currentStep = [object valueForKeyPath:keyPath];
    }
    
}

//------------------------------------------------------------------------------
// Overwrotten methods.

#pragma mark – Rewrotten

/*!
 * @method      showWindow:
 * @abstract    Triggers the creation of the file only when the window is
 *              visible and then release.
 */
- (IBAction)showWindow:(id)sender {
    [super showWindow: sender];
    
    NSLog(@"%@", imageUtility);

    [_currentProgressBar setIndeterminate: NO];
//    [_currentProgressBar setUsesThreadedAnimation:YES];
    [_currentProgressBar startAnimation:self];

    if ([[imageUtility fileSystem] isEqualToString:@"HFS"]) {
        [imageUtility generateHFSImage];
    } else if ([[imageUtility fileSystem] isEqualToString:@"HFS+"]) {
        [imageUtility generateHFSPlusImage];
    }    
    
    [self release];
}

//------------------------------------------------------------------------------
// Standard methods.

#pragma mark – Standard methods

/*!
 * @link Check XCode quick help.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
}

@end
