//
//  LastifyController.h
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import <Cocoa/Cocoa.h>
#import "LastifyLastfmClient.h"


@interface LastifyController : NSObject 
{
	IBOutlet NSDrawer *drawer;
	LastifyLastfmClient *lastfm;
}

@property(readonly, retain) LastifyLastfmClient *lastfm;

+ (BOOL)renameSelector:(SEL)originalSelector toSelector:(SEL)newSelector onClass:(Class)class;
+ (LastifyController*)sharedInstance;

- (void)initLastfmConnection;
- (void)loadUserInterface;

- (IBAction)authComplete:(id)sender;
- (IBAction)loveTrack:(id)sender;
- (IBAction)banTrack:(id)sender;

@end
