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
	IBOutlet NSPanel *tagPanel;
	IBOutlet NSTokenField *tagField;
	LastifyLastfmClient *lastfm;
	
	IBOutlet NSButton *loveButton;
	IBOutlet NSButton *banButton;
	IBOutlet NSButton *tagButton;
	IBOutlet NSButton *loginButton;
	
	NSString *currentTrack;
	NSString *currentArtist;
	NSArray *currentTags;
}

@property(readonly, retain) LastifyLastfmClient *lastfm;
@property(readwrite, retain) NSString *currentTrack;
@property(readwrite, retain) NSString *currentArtist;
@property(readwrite, retain) NSArray *currentTags;

+ (BOOL)renameSelector:(SEL)originalSelector toSelector:(SEL)newSelector onClass:(Class)class;
+ (LastifyController*)sharedInstance;

- (void)initLastfmConnection;
- (void)loadUserInterface;

- (IBAction)loveTrack:(id)sender;
- (IBAction)banTrack:(id)sender;
- (IBAction)tagTrack:(id)sender;

- (IBAction)taggingOK:(id)sender;
- (IBAction)taggingCancel:(id)sender;

- (IBAction)auth:(id)sender;

@end
