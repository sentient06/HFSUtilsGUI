//
//  ImageUtility.m
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

#import "ImageUtility.h"

//------------------------------------------------------------------------------

@implementation ImageUtility

//------------------------------------------------------------------------------
// Synthesisers

@synthesize pathToFile
          , volumeLabel
          , realPathToCopyFrom
          , virtualPathTocopyTo
          , fileSystem
          , currentActionDescription; //NSString
@synthesize volumeSize
          , volumeSizeUnity
          , currentActionProgress = _currentActionProgress; //int

//------------------------------------------------------------------------------
// Methods

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void) dealloc {
    [ddPath release];
    [pvPath release];
    [hformatPath release];
    [hmountPath release];
    [hcdPath release];
    [hmkdirPath release];
    [hcopyPath release];
    [humountPath release];
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
        ddPath = [[NSString alloc] initWithString:@"/bin/dd"];
        pvPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"pv" ]];
        hformatPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hformat" ]];
        hmountPath  = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hmount" ]];
        hcdPath     = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hcd" ]];
        hmkdirPath  = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hmkdir" ]];
        hcopyPath   = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hcopy" ]];
        humountPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/humount" ]];
        _currentActionProgress = 0;
    }
    return self;
}

//------------------------------------------------------------------------------

#pragma mark – Actions

/*!
 * @method      generateImage
 * @abstract    Creates an empty file with 'dd'.
 */
- (void)generateImage {
    
    // /bin/dd if=/dev/zero bs=1048576 count=500 |/Users/gian/Desktop/pv -cb|/bin/dd of=/Users/gian/Desktop/TestDisk.img
    
    NSLog(@"GENERATE");
    
    int volumeBS = 0;
    
    switch (volumeSizeUnity) {
        case Bytes:
            volumeBS = 1;
        break;
        default:
        case KyloBytes:
            volumeBS = 1024;
        break;
        case MegaBytes:
            volumeBS = 1048576;
        break;
        case Gigabytes:
            volumeBS = 1073741824;
        break;
    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Testing progress

        
    
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Tasks
    
    NSTask * d1Task = [[[NSTask alloc] init] autorelease];
    NSTask * pvTask = [[[NSTask alloc] init] autorelease];
    NSTask * d2Task = [[[NSTask alloc] init] autorelease];
    
    // Pipes
    NSPipe * dd_to_pvPipe = [NSPipe pipe];
    NSPipe * pv_to_ddPipe = [NSPipe pipe];
    NSPipe * pvStderrPipe = [NSPipe pipe];
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Creates empty image
    
    // Sets the tasks' details:
    
    NSLog(@"Creating empty image of %d x %d", volumeSize, volumeBS );
    self.currentActionDescription = @"Writting blocks to file...";
    
    [d1Task setLaunchPath:ddPath];
    [pvTask setLaunchPath:pvPath];
    [d2Task setLaunchPath:ddPath];
    
    [d1Task setArguments:
        [NSArray arrayWithObjects:
             @"if=/dev/zero"
           , [NSString stringWithFormat:@"bs=%d", volumeBS]
           , [NSString stringWithFormat:@"count=%d", volumeSize]
           ,nil
        ]
    ];
    
    [d2Task setArguments:
        [NSArray arrayWithObjects:
            [NSString stringWithFormat:@"of=%@", pathToFile]
           ,nil
        ]
    ];
    
    [pvTask setArguments:
        [NSArray arrayWithObjects:
             @"-Wn"
           , [NSString stringWithFormat:@"-s %lu", volumeBS * volumeSize]
           , nil
        ]
    ];

    // Associates pipes:
    
    [d1Task setStandardOutput: dd_to_pvPipe];
    [pvTask setStandardInput : dd_to_pvPipe];
    [pvTask setStandardOutput: pv_to_ddPipe];
    [pvTask setStandardError : pvStderrPipe];
    [d2Task setStandardInput : pv_to_ddPipe];
    
    // Block to check progress:

    NSFileHandle * pvError = [pvStderrPipe fileHandleForReading];

    [pvError waitForDataInBackgroundAndNotify];
    
    __block ImageUtility * blockSafeSelf = self;
    
    id myBlock = [^(NSNotification *note) {
        
        NSData   * progressData = [pvError availableData];
        NSString * progressStr  = [
            [NSString alloc] initWithData:progressData
            encoding:NSUTF8StringEncoding
        ];
        if (![progressStr isEqualToString:@""]
            && ![progressStr isEqualTo:nil] ) {
            
            NSDecimalNumber * amountNumber = [NSDecimalNumber decimalNumberWithString:progressStr];

            blockSafeSelf.currentActionProgress = amountNumber;
//            NSLog(@"+--- %@", progressStr);
//            NSLog(@"| -- %@", amountNumber);
//            NSLog(@"+--- %@", blockSafeSelf->_currentActionProgress);
        }
        [progressStr release];
        [pvError waitForDataInBackgroundAndNotify];
    } copy ];// autorelease];

    // Observes progress:
    
    [ [NSNotificationCenter defaultCenter]
          addObserverForName:NSFileHandleDataAvailableNotification
                      object:pvError
                       queue:nil
                  usingBlock:myBlock
    ];
    
    // Launches tasks:
    
    [d1Task launch];
    [pvTask launch];
    [d2Task launch];
    
    [d1Task waitUntilExit];
    [pvTask waitUntilExit];
    [d2Task waitUntilExit];
    
    // Removes objects:
    
    [[NSNotificationCenter defaultCenter] removeObserver:NSFileHandleDataAvailableNotification];
    [myBlock release];
    
    NSLog(@"Image saved!");
    
}

/*!
 * @method      formatHFS
 * @abstract    Formats an empty file into an HFS disk image.
 */
- (void)formatHFS {
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Tasks
    
    NSTask * fileSystemTask = [[[NSTask alloc] init] autorelease];
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Formats to HFS

    NSLog(@"Formating with HFS");
    self.currentActionDescription = @"Formating with HFS...";

    [fileSystemTask setLaunchPath:hformatPath];
    [fileSystemTask setArguments:
        [NSArray arrayWithObjects:
             @"-l"
           , volumeLabel
           , pathToFile
           , nil
        ]
    ];
    [fileSystemTask launch];
    [fileSystemTask waitUntilExit];

    NSLog(@"Image formated!");
    
}

//- (void)generic {
//    //    dd if=/dev/zero of=/Users/gian/Desktop/HFSTools/MacOS755.img bs=1048576 count=25
//    //    ./hformat -l "System 7.5.3" ../MacOS755.img
//    //    ./hmount ../MacOS755.img
//    //    ./hmkdir "Mac OS 7.5.3 Install Segments"
//    //    ./hcopy -r "../IS/B-System 7.5.3 01of19.smi" "System 7.5.3:Mac OS 7.5.3 Install Segments:"
//    //    ./hcd "Mac OS 7.5.3 Install Segments"
//    //    ./hmkdir "test"
//    //    ./hcd
//    //    ./hcd "Mac OS 7.5.3 Install Segments"
//    //    ./humount
//    
//    
//    //--------------------------------------------------------------------------
//    // Tasks
//    
//    NSTask * imageTask      = [[[NSTask alloc] init] autorelease];
//    NSTask * fileSystemTask = [[[NSTask alloc] init] autorelease];
//    NSTask * mountTask      = [[[NSTask alloc] init] autorelease];
//    NSTask * unmountTask    = [[[NSTask alloc] init] autorelease];
//    
//    //--------------------------------------------------------------------------
//    // Executable paths
//    
//    NSString * hformatPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hformat" ]];
//    NSString * hmountPath  = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hmount" ]];
//    NSString * hcdPath     = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hcd" ]];
//    NSString * hmkdirPath  = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hmkdir" ]];
//    NSString * hcopyPath   = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/hcopy" ]];
//    NSString * humountPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"HFSTools/humount" ]];
//    
//    NSString * nameOfDisk    = @"System 7.5.3";
//    NSString * addressOfDisk = @"/Users/gian/Desktop/HFSToolsGUIImage.img";
//    
//    //--------------------------------------------------------------------------
//    // Creates empty image
//    
//    NSLog(@"Creating empty image of 25MB");
//    
//    [imageTask setLaunchPath:@"/bin/dd"];
//    [imageTask setArguments:
//        [NSArray arrayWithObjects:
//             @"if=/dev/zero"
//           , [NSString stringWithFormat:@"of=%@", addressOfDisk]
//           , @"bs=1048576"
//           , @"count=25"
//           ,nil
//        ]
//    ];
//    [imageTask launch];
//    [imageTask waitUntilExit];
//    NSLog(@"Image saved!");
//    
//    //--------------------------------------------------------------------------
//    // Formats to HFS
//    
//    NSLog(@"Formating with HFS");
//    
//    [fileSystemTask setLaunchPath:hformatPath];
//    [fileSystemTask setArguments:
//        [NSArray arrayWithObjects:
//             @"-l"
//           , nameOfDisk
//           , addressOfDisk
//           , nil
//        ]
//    ];
//    [fileSystemTask launch];
//    [fileSystemTask waitUntilExit];
//    
//    NSLog(@"Image formated!");
//    
//    //--------------------------------------------------------------------------
//    // Mounts image
//    
//    NSLog(@"Mounting image");
//    
//    [mountTask setLaunchPath:hmountPath];
//    [mountTask setArguments:
//        [NSArray arrayWithObjects:
//             addressOfDisk
//           , nil
//        ]
//    ];
//    [mountTask launch];
//    [mountTask waitUntilExit];
//    
//    NSLog(@"Image mounted!");
//
//    //--------------------------------------------------------------------------
//    // Creates files
//    
//    // http://stackoverflow.com/questions/4767512/iterating-through-all-the-subfolders-of-a-folder-in-iphone
//    // http://snipplr.com/view/23016/
//    
//   
//    // Using local variable, the alloc will throw an error even releasing.
////    NSString      * rootPath     = [ NSString stringWithFormat: @"/Users/gian/Desktop/KeanuMinecraft.png" ];
//    NSString      * rootPath     = [ NSString stringWithFormat: @"/Users/gian/Desktop/Mac OS 7.5.3 Install Segments" ];
//    NSString      * rootPathName = [rootPath lastPathComponent];
//    NSFileManager * fileManager  = [NSFileManager defaultManager];
//    
//    BOOL isDir;
//    
//    if (rootPath && ([fileManager fileExistsAtPath:rootPath isDirectory:&isDir] && isDir)) {
//        
//        if (![rootPath hasSuffix:@"/"]) {
//            rootPath = [rootPath stringByAppendingString:@"/"];
//        }
//        
//        // Makes root dir
//        NSTask * rootDirectoryTask = [[NSTask new] autorelease];
//        [rootDirectoryTask setLaunchPath:hmkdirPath];
//        [rootDirectoryTask setArguments:
//            [NSArray arrayWithObjects:
//                 rootPathName
//               , nil
//            ]
//        ];
//        
//        [rootDirectoryTask launch];
//        [rootDirectoryTask waitUntilExit];
//        //----------------------------------------------------------------------
//        // Walks the |rootDirectory| recurisively
//        
//        NSDirectoryEnumerator * dirEnumerator = [fileManager enumeratorAtPath:rootPath];
//        NSString * filename;
//        NSString * fullFilePath;
//        
//        while ((filename = [dirEnumerator nextObject])) {
//            
//            // Makes the filename |filename| a fully qualifed filename
//            fullFilePath = [rootPath stringByAppendingString:filename];
//            NSUInteger lengthOfRoot = [fullFilePath rangeOfString:rootPathName].location;
//            NSString * HFSFilePath = [fullFilePath substringWithRange: NSMakeRange(lengthOfRoot, [fullFilePath length]-lengthOfRoot)];
//            HFSFilePath = [NSString stringWithFormat: @"%@/%@/", nameOfDisk, [HFSFilePath stringByDeletingLastPathComponent]];
//            HFSFilePath = [HFSFilePath stringByReplacingOccurrencesOfString:@"/" withString:@":"];
//            
//            if ([fileManager fileExistsAtPath:fullFilePath isDirectory:&isDir] && isDir) {
//                
//                //--------------------------------------------------------------    
//                // Directory
//                
//                // Here is some messy stuff...
//                // We must cd to the right place before creating a dir.
//                // Each cd requires a task.
//                //
//                //    ./hmkdir "test"
//                //    ./hcd
//                //    ./hcd "Mac OS 7.5.3 Install Segments"
//                
//                NSLog(@"Original DIR: %@", fullFilePath);
//                NSLog(@"Destiny.....: %@", HFSFilePath);
//                
//                // CD to parent dir
//                NSLog(@"cd");
//                NSTask * cdToOriginalTask = [[NSTask alloc] init];
//                [cdToOriginalTask setLaunchPath:hcdPath];
//                [cdToOriginalTask launch];
//                [cdToOriginalTask waitUntilExit];
//                [cdToOriginalTask release];
//
//                NSString * cdDirectory;
//                for (cdDirectory in [HFSFilePath componentsSeparatedByString:@":"]) {
//                    NSLog(@"cd %@", cdDirectory);
//                    NSTask * cdToDirTask = [[NSTask alloc] init];
//                    [cdToDirTask setLaunchPath:hcdPath];
//                    [cdToDirTask setArguments:[NSArray arrayWithObjects:cdDirectory, nil]];
//                    [cdToDirTask launch];
//                    [cdToDirTask waitUntilExit];
//                    [cdToDirTask release];
//                }
//
//                NSTask * singleDirTask = [[NSTask alloc] init];
//
//                // Creates dir
//                [singleDirTask setLaunchPath:hmkdirPath];
//                [singleDirTask setArguments:
//                    [NSArray arrayWithObjects:
//                         [fullFilePath lastPathComponent]
//                       , nil
//                    ]
//                ];
//
//                [singleDirTask launch];
//                [singleDirTask waitUntilExit];
//                [singleDirTask release];
//                
//            } else {
//                
//                //--------------------------------------------------------------    
//                // File
//            
//                NSTask * singleCopyTask = [[NSTask alloc] init];
//                NSLog(@"Original: %@", fullFilePath);
//                NSLog(@"Destiny.: %@", HFSFilePath);
//
//                // Copies file
//                [singleCopyTask setLaunchPath:hcopyPath];
//                [singleCopyTask setArguments:
//                    [NSArray arrayWithObjects:
//                         @"-r"
//                       , fullFilePath
//                       , HFSFilePath
//                       , nil
//                    ]
//                ];
//
//                [singleCopyTask launch];
//                [singleCopyTask waitUntilExit];
//                [singleCopyTask release];
//            
//            }
//            
//             NSLog(@"\n\n");            
//            
//        }
//        
//    } else {
//        
//        //Move file!
//
////        NSUInteger lengthOfRoot = [rootPath rangeOfString:rootPathName].location;
////        NSString * HFSFilePath = [rootPath substringWithRange: NSMakeRange(lengthOfRoot, [rootPath length]-lengthOfRoot)];
////        HFSFilePath = [NSString stringWithFormat: @"%@/%@/", nameOfDisk, rootPathName];
//        NSString * HFSFilePath = [NSString stringWithFormat: @"%@/%@/", nameOfDisk, rootPathName];
//        HFSFilePath = [HFSFilePath stringByReplacingOccurrencesOfString:@"/" withString:@":"];
//        
//        NSTask * singleCopyTask = [[NSTask alloc] init];
//        NSLog(@"Original: %@", rootPath);
//        NSLog(@"Destiny.: %@", HFSFilePath);
//
//        // Copies file
//        [singleCopyTask setLaunchPath:hcopyPath];
//        [singleCopyTask setArguments:
//            [NSArray arrayWithObjects:
//                 @"-r"
//               , rootPath
//               , HFSFilePath
//               , nil
//            ]
//        ];
//
//        [singleCopyTask launch];
//        [singleCopyTask waitUntilExit];
//        [singleCopyTask release];
//
//        
//    }
//
//    //--------------------------------------------------------------------------
//    // Unmounts image
//    
//    NSLog(@"Unmounting image");
//    
//    [unmountTask setLaunchPath:humountPath];
//    [unmountTask setArguments:
//        [NSArray arrayWithObjects:
//             @"/Users/gian/Desktop/HFSToolsGUIImage.img"
//           , nil
//        ]
//    ];
//    [unmountTask launch];
//    [unmountTask waitUntilExit];
//    
//    NSLog(@"Image unmounted!");
//
//    [humountPath release];
//    [hcopyPath   release];
//    [hmkdirPath  release];
//    [hcdPath     release];
//    [hmountPath  release];
//    [hformatPath release];
//    
//    
////    NSNumber * mySize = [NSNumber numberWithUnsignedLongLong:[[[NSFileManager defaultManager] attributesOfItemAtPath:someFilePath error:nil] fileSize]];
//    
//    
//
//}

//------------------------------------------------------------------------------
// Methods.

#pragma mark – Default methods

/*!
 * @method      description
 * @abstract    Returns a summary of the main class' variables.
 */
- (NSString *)description {
    
    NSString * descr = [
        [NSString alloc]
            initWithFormat:
        @"\nPath .... %@\nLabel ... %@\nSize .... %d\nUnit .... %d\nFlsys ... %@", 
        [self pathToFile],
        [self volumeLabel],
        [self volumeSize],
        [self volumeSizeUnity],
        [self fileSystem]
    ];
    return [descr autorelease];
}

@end
