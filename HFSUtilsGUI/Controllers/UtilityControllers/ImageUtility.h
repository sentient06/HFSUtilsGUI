//
//  ImageUtility.h
//  HFSUtilsGUI
//
//  Created by Giancarlo Mariot on 24/05/2013.
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

#import <Foundation/Foundation.h>

enum SizeUnits {
    Bytes     = 1,
    KyloBytes = 2,
    MegaBytes = 3,
    Gigabytes = 4
};

/*!
 * @class       ImageUtility:
 * @abstract    Responsible for all the HFSTools actions.
 * @discussion  This is the key class of this project. Everything is made using
 *              NSTasks.
 */
@interface ImageUtility : NSObject {

    // HFSUtils path - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    NSString * ddPath;
    NSString * pvPath;
    NSString * hdiutilPath;
    
    NSString * hformatPath;
    NSString * hmountPath;
    NSString * hcdPath;
    NSString * hmkdirPath;
    NSString * hcopyPath;
    NSString * humountPath;
    
    BOOL running;
    unsigned long long currentFileSize;

}

//------------------------------------------------------------------------------
// Actions' properties.

@property (copy) NSString * pathToFile
                        , * volumeLabel
                        , * realPathToCopyFrom
                        , * virtualPathTocopyTo
                        , * fileSystem
                        , * currentActionDescription;

@property int volumeSize
            , volumeSizeUnity
            ;

@property (copy, nonatomic) NSDecimalNumber * currentActionProgress;

//------------------------------------------------------------------------------
// Actions

- (void)generateBlankImage;
- (void)formatHFS;
- (void)generateHFSImage;
- (void)generateHFSPlusImage;

@end
