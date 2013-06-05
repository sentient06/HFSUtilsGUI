//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "CreateImageWindowController.h" //Progress bar window

//------------------------------------------------------------------------------

@implementation AppDelegate

//------------------------------------------------------------------------------
// Application synthesisers.

@synthesize window = _window;

//------------------------------------------------------------------------------
// Standard variables synthesisers.

@synthesize pathToFile; //NSUrl
@synthesize allowedTypesOfImage
          , sizesListForImage
          , allowedFormatsOfImage; //NSArray
@synthesize savePanel; //NSSavePanel

//------------------------------------------------------------------------------
// Methods.

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [super dealloc];
}

// Init methods

#pragma mark – Init

/*!
 * @method      init
 * @abstract    Init method.
 */
- (id)init {
    self = [super init];
    if (self) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    }
    return self;
}

//------------------------------------------------------------------------------

#pragma mark – Main Window actions

/*!
 * @method      quitApplication:
 * @abstract    Quits application.
 */
- (IBAction)quitApplication:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

/*!
 * @method      saveNewImage:
 * @abstract    Triggers the save sheet and prepares the information to be
 *              passed to the next controller.
 */
- (IBAction)saveNewImage:(id)sender {
    
    // Prepares the save sheet:
    savePanel = [NSSavePanel savePanel];

  //[savePanel setNameFieldStringValue:@"Default name of file"];
    [savePanel setAccessoryView:newImageAccessory];
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger returnCode) {
        
        if (returnCode == NSFileHandlingPanelOKButton) {
            
            [savePanel orderOut:self];

            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Parsing strings to identify chosen size:
            
            NSString * valueOfSizePopUp = [imageSize titleOfSelectedItem];
            NSString * valueOfSizePopUpToParse;
            
            NSRange customPosition                  = [valueOfSizePopUp rangeOfString:@"Custom"];
            NSRange customLeftRoundBracketPosition  = [valueOfSizePopUp rangeOfString:@"("];
            NSRange customRightRoundBracketPosition = [valueOfSizePopUp rangeOfString:@")"];
            
            BOOL usesCustomSize = !(customPosition.location == NSNotFound);
            BOOL hasBrackets    = !(customLeftRoundBracketPosition.location == NSNotFound);
            
            NSRange sizeRange;
            
            if (usesCustomSize) {

                sizeRange = NSMakeRange(
                    customLeftRoundBracketPosition.location + 1,
                    customRightRoundBracketPosition.location - customLeftRoundBracketPosition.location-1
                );
                valueOfSizePopUpToParse = [valueOfSizePopUp substringWithRange:sizeRange];
                
            } else {
                
                if (hasBrackets) {
                    sizeRange = NSMakeRange(0, customLeftRoundBracketPosition.location-1);
                    valueOfSizePopUpToParse = [valueOfSizePopUp substringWithRange:sizeRange];
                } else {
                    valueOfSizePopUpToParse = valueOfSizePopUp;
                }
                
            }
            
            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Getting size and unit:
            
            NSArray           * sizeData       = [valueOfSizePopUpToParse componentsSeparatedByString:@" "];  // 5-MB
            NSNumberFormatter * sizeFormatter  = [[[NSNumberFormatter alloc] init] autorelease];
            NSNumber          * sizeNumber     = [sizeFormatter numberFromString:[sizeData objectAtIndex:0]]; // 5
            NSString          * sizeUnitString = [sizeData objectAtIndex:1]; // MB
            
            if ([[sizeData objectAtIndex:0] isEqualToString:@"1.44"]) {
                sizeNumber = [NSNumber numberWithInt:1440];
                sizeUnitString = @"KB";
            }
            
            int sizeUnitInt = 2;

            if ([sizeUnitString isEqualToString:@"KB"]) sizeUnitInt = 2;
            if ([sizeUnitString isEqualToString:@"MB"]) sizeUnitInt = 3;
            if ([sizeUnitString isEqualToString:@"GB"]) sizeUnitInt = 4;
            
            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Security measures:
            
            // 1509949 == 1.44MB (floppy)
            
            // Minimum required for HFSUtils is 800KB
            if (sizeUnitInt == 2 && [sizeNumber intValue] < 80 ) {
                sizeNumber = [NSNumber numberWithInt:800];
            }
            
            // Do not go over 2GB
            if (sizeUnitInt == 3 && [sizeNumber intValue] > 2048 ) {
                sizeNumber = [NSNumber numberWithInt:2048];
            }

            // Do not go over 2GB
            if (sizeUnitInt == 4 && [sizeNumber intValue] > 2 ) {
                sizeNumber = [NSNumber numberWithInt:2];
            }

            // Do not allow empty labels
            NSString * volumeLabel = [NSString stringWithString:[imageLabel stringValue]];
            if ([volumeLabel isEqualToString:@""]) {
                volumeLabel = [NSString stringWithString:[[savePanel URL] lastPathComponent]];
            }

            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Trigger creation of image:
            
            [self saveImageToPath:[savePanel URL]
                         withType:[imageType titleOfSelectedItem]
                         andLabel:volumeLabel
                          andSize:sizeNumber
                           inUnit:sizeUnitInt
                     onFileSystem:[imageFsys titleOfSelectedItem]
            ];           
           
            
        } else {
            NSLog(@"Sheet canceled");
        }
    }];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*!
 * @method      saveImageToPath:withType:andLabel:andSize:inUnit:onFileSystem:
 * @abstract    Triggers the action to save the image in a GCD thread.
 */
- (void) saveImageToPath:(NSURL*)filePath
                withType:(NSString*)volumeType
                andLabel:(NSString*)volumeLabel
                 andSize:(NSNumber*)volumeSize
                  inUnit:(int)sizeUnit
            onFileSystem:(NSString*)fileSystem {
    
    dispatch_async(queue, ^{

        CreateImageWindowController * newAction = [[CreateImageWindowController alloc]
               initWithWindowNibName:@"CreateImageWindow"
               withPath:filePath
               andType:volumeType
               andLabel:volumeLabel
               andSize:volumeSize
               inUnit:sizeUnit
               onFileSystem:fileSystem
        ];
    
        [newAction showWindow:self];
    });
    
}

//------------------------------------------------------------------------------
// Rewritten methods.

#pragma mark – Rewritten methods

/*!
 * @abstract Quits application when window is closed.
 * @link     Check XCode quick help.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

//------------------------------------------------------------------------------
// Standard methods.

#pragma mark – Standard methods

/*!
 * @link Check XCode quick help.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setAllowedTypesOfImage:  [NSArray arrayWithObjects:@".dmg", @".img", nil]];
    [self setSizesListForImage:    [NSArray arrayWithObjects:@"5 MB", nil]];
    [self setAllowedFormatsOfImage:[NSArray arrayWithObjects:@"HFS", @"HFS+", nil]];
}


@end
