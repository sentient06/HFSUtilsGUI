//
//  CreateDiskUtilityController.m
//  HFSUtilsGUI
//
//  Created by Giancarlo Mariot on 26/05/2013.
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

#import "CustomDiskSizeWindowController.h"

//------------------------------------------------------------------------------

@implementation CustomDiskSizeWindowController

//------------------------------------------------------------------------------
// Synthesisers

@synthesize customSizeView = _customSizeView;
@synthesize popUpSizeTitle;

//------------------------------------------------------------------------------
// Init methods

#pragma mark – Init

/*!
 * @method      init
 * @abstract    Init method.
 */
- (id)init {
    self = [super init];
    if (self) {
        popUpSizeTitle = @"Custom...";
    }
    return self;
}

//------------------------------------------------------------------------------

#pragma mark – Window actions

/*!
 * @method      displayCustomSizeView:
 * @abstract    Shows the custom size's sheet.
 */
- (IBAction)displayCustomSizeView:(id)sender{

    if (!_customSizeView) {
        [NSBundle loadNibNamed:@"CustomDiskSizeWindow" owner:self];
    }

    [ NSApp
            beginSheet: self.customSizeView
        modalForWindow: [[NSApp delegate] savePanel]
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      closeCustomSizeView:
 * @abstract    Hides the custom size's sheet.
 */
- (IBAction)closeCustomSizeView:(id)sender {
    [NSApp endSheet: self.customSizeView];
    [self.customSizeView close];
    self.customSizeView = nil;
}

/*!
 * @method      confirmCustomSize:
 * @abstract    Changes popup item's label and hides the custom size's sheet.
 */
- (IBAction)confirmCustomSize:(id)sender {
    NSLog(@"%@", [customSizeTextField stringValue]);
    NSLog(@"%@", [customSizeUnitPopUp titleOfSelectedItem]);

    [self setPopUpSizeTitle:[
            NSString stringWithFormat:@"Custom... (%@ %@)",
            [customSizeTextField stringValue],
            [customSizeUnitPopUp titleOfSelectedItem]
        ]
    ];

    [NSApp endSheet: self.customSizeView];
    [self.customSizeView close];
    self.customSizeView = nil;
}

@end
