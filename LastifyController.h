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
	IBOutlet NSPanel *playlistPanel;
	IBOutlet NSArrayController *playlistsController;
	LastifyLastfmClient *lastfm;
	
	IBOutlet NSButton *loveButton;
	IBOutlet NSButton *banButton;
	IBOutlet NSButton *tagButton;
	IBOutlet NSButton *listButton;
	IBOutlet NSButton *loginButton;
	
	IBOutlet NSImageView *statusImage;
	
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

- (void)startNewTrack:(NSString*)trackName byArtist:(NSString*)artistName;

- (void)displayWorkingIcon;
- (void)displayResultIcon:(BOOL)result;

- (IBAction)loveTrack:(id)sender;
- (IBAction)banTrack:(id)sender;

- (IBAction)tagTrack:(id)sender;
- (IBAction)taggingOK:(id)sender;
- (IBAction)taggingCancel:(id)sender;

- (IBAction)addTrackToPlaylist:(id)sender;
- (IBAction)playlistOK:(id)sender;
- (IBAction)playlistCancel:(id)sender;

- (IBAction)auth:(id)sender;

@end
