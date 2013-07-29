//
//  ImageFilesOutlineViewController.m
//  HFSUtilsGUI
//
//  Created by Giancarlo Mariot on 06/06/2013.
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


#import "ImageFilesOutlineViewController.h"

@implementation ImageFilesOutlineViewController

@synthesize imageFiles = _imageFiles;

- (id)init {
    self = [super init];
    if (self) {

//        _imageFiles = [[NSMutableArray alloc] init];
//        ImageFileModel * test = [[ImageFileModel alloc] initWithName:@"Empty"];
//        [_imageFiles addObject:test];
        
    }
    return self;
}

- (id)initWithArray:newArray {
    self = [super init];
    if (self) {
        _imageFiles = newArray;
    }
    return self;
}

// Mandatory here:

// Asks for the number of children for an specific item.
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return !item ? [self.imageFiles count] : [[item children] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return !item ? YES : [[item children] count] != 0;
}

// Asking to a parent item for a specific child based on its index.
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    // if no item, look in the index level, else look for child.
    return !item ? [self.imageFiles objectAtIndex:index] : [[item children] objectAtIndex:index];
}

// Asking for value at a specific column.
- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item {
    if ([[tableColumn identifier] isEqualToString:@"name"]) {
        return [item name];
    }
    
    return @"Empty!";
    
}


@end
