//
//  LastifyController.h
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LastifyController : NSObject 
{
	IBOutlet NSDrawer *drawer;
}

+ (BOOL)renameSelector:(SEL)originalSelector toSelector:(SEL)newSelector onClass:(Class)class;
+ (LastifyController*)sharedInstance;

- (void)loadUserInterface;
- (IBAction)loveTrack:(id)sender;
- (IBAction)banTrack:(id)sender;

@end
