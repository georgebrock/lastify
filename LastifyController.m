//
//  LastifyController.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import <objc/objc-class.h>
#import "LastifyController.h"
#import "SPController.h"
#import "SPController+Lastify.h"
#import "SPGrowlDelegate+Lastify.h"
#import "NSButton+Lastify.h"

@implementation LastifyController

@synthesize 
	lastfm,
	currentTrack,
	currentArtist,
	currentTags;

+ (void)load
{
	[SPController initLastify];
	[SPGrowlDelegate initLastify];
	[[LastifyController sharedInstance] initLastfmConnection];
}

+ (LastifyController*)sharedInstance
{
	static LastifyController *plugin = nil;
	
	if(!plugin)
		plugin = [[LastifyController alloc] init];
		
	return plugin;
}

+ (BOOL)renameSelector:(SEL)originalSelector toSelector:(SEL)newSelector onClass:(Class)class
{
	Method method = nil;

	method = class_getInstanceMethod(class, originalSelector);
	if (method == nil)
			return NO;
	
	method->method_name = newSelector;
	return YES;
}

- (void)dealloc
{
	[lastfm release], lastfm = nil;
	[currentTrack release], currentTrack = nil;
	[currentArtist release], currentArtist = nil;
	[currentTags release], currentTags = nil;
	[super dealloc];
}

- (void)initLastfmConnection
{
	lastfm = [[LastifyLastfmClient alloc] initWithAPIKey:@"aa31898c9c79401a7ddaa6c8f089ccad" APISecret:@"92773b344ec2e14cd6f5780b83c06265"];
	[lastfm authenticateQuietly];
}

- (void)loadUserInterface
{
	[NSBundle loadNibNamed:@"LastifyInterface" owner:self];
	
	[statusImage setImage:nil];
	
	[loveButton setTextColor:[NSColor whiteColor]];
	[banButton setTextColor:[NSColor whiteColor]];
	[tagButton setTextColor:[NSColor whiteColor]];
	[loginButton setTextColor:[NSColor whiteColor]];
	[listButton setTextColor:[NSColor whiteColor]];
	
	[drawer setParentWindow:[[SPController sharedController] mainWindow]];
	NSSize contentSize = NSMakeSize(71, 200);
	[drawer setMaxContentSize:contentSize];
	[drawer setMinContentSize:contentSize];
	[drawer setLeadingOffset:29];
	[drawer setTrailingOffset:10];
	[drawer openOnEdge:NSMaxXEdge];
	[drawer setDelegate:self];
	
	[drawer setContentSize:contentSize];
}

- (void)displayWorkingIcon
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"icon_loading" ofType:@"gif"];
	NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
	[statusImage setImage:img];
	[img release], img = nil;
}

- (void)displayResultIcon:(BOOL)result
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:(result ? @"icon_tick" : @"icon_error") ofType:@"png"];
	NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
	[statusImage setImage:img];
	[img release], img = nil;
	
	[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(clearResultIcon:) userInfo:nil repeats:FALSE];
}

- (void)clearResultIcon:(NSTimer*)timer
{
	[statusImage setImage:nil];
}

- (IBAction)auth:(id)sender
{
	if(lastfm.sessionKey)
		return;
	
	[lastfm authenticateQuietly];
	if(lastfm.sessionKey)
		return;
		
	NSAlert *authAlert = [NSAlert 
		alertWithMessageText:@"You must authorise Lastify to access your Last.fm profile information"
		defaultButton:@"Continue"
		alternateButton:@"Cancel"
		otherButton:nil
		informativeTextWithFormat:@"If you click 'Continue' the Last.fm website will open so you can authorise Lastify"];
	
	if([authAlert runModal] == NSAlertAlternateReturn)
		return;

	[lastfm authenticate];
	
	if(lastfm.waitingForUserAuth)
	{
		NSAlert *authCompleteAlert = [NSAlert 
			alertWithMessageText:@"Authorisation is complete"
			defaultButton:@"Continue"
			alternateButton:@"Cancel"
			otherButton:nil
			informativeTextWithFormat:@"I've authorised Lastify to access my Last.fm profile"];
			
		if([authCompleteAlert runModal] == NSAlertAlternateReturn)
			return;
			
		[lastfm startNewSession];
	}
}

- (IBAction)loveTrack:(id)sender
{
	if(!currentTrack || !currentArtist)
		return;

	[self displayWorkingIcon];
	BOOL result = [lastfm loveTrack:currentTrack byArtist:currentArtist];
	[self displayResultIcon:result];
}

- (IBAction)banTrack:(id)sender
{
	if(!currentTrack || !currentArtist)
		return;
	
	[self displayWorkingIcon];
	BOOL result = [lastfm banTrack:currentTrack byArtist:currentArtist];
	[self displayResultIcon:result];
}

- (IBAction)tagTrack:(id)sender
{
	self.currentTags = [lastfm getTagsForTrack:currentTrack byArtist:currentArtist];
	[tagField setObjectValue:self.currentTags];
	[NSApp beginSheet:tagPanel modalForWindow:[[SPController sharedController] mainWindow] modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)taggingOK:(id)sender
{	
	[self displayWorkingIcon];
	
	NSArray *newTags = [tagField objectValue];
	NSMutableArray *removeTags = [self.currentTags mutableCopy];
	NSMutableArray *addTags = [NSMutableArray arrayWithCapacity:[newTags count]];

	NSEnumerator *tagEnum = [newTags objectEnumerator];
	NSString *tag;
	while(tag = [tagEnum nextObject])
	{
		[removeTags removeObject:tag];
		
		if(![self.currentTags containsObject:tag])
			[addTags addObject:tag];
	}

	BOOL result = TRUE;
	
	if([addTags count] > 0)
	{
		NSLog(@"LASTIFY Adding tags: %@", addTags);
		result = [lastfm addTags:addTags toTrack:currentTrack byArtist:currentArtist] && result;
	}

	if([removeTags count] > 0)
	{
		NSLog(@"LASTIFY Removing tags: %@", removeTags);
		result = [lastfm removeTags:removeTags fromTrack:currentTrack byArtist:currentArtist] && result;
	}

	[removeTags release], removeTags = nil;

	[tagPanel orderOut:nil];
	[NSApp endSheet:tagPanel];
	
	[self displayResultIcon:result];
}

- (void)startNewTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	NSLog(@"LASTIFY track started: \"%@\" by %@", trackName, artistName);
	self.currentTrack = trackName;
	self.currentArtist = artistName;
}

- (IBAction)taggingCancel:(id)sender
{
	[tagPanel orderOut:nil];
	[NSApp endSheet:tagPanel];
}

- (IBAction)addTrackToPlaylist:(id)sender
{
	[playlistsController setContent:[lastfm getPlaylists]];
	[NSApp beginSheet:playlistPanel modalForWindow:[[SPController sharedController] mainWindow] modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)playlistOK:(id)sender
{
	NSDictionary *selectedPlaylist = [[playlistsController selectedObjects] objectAtIndex:0];
	if(!selectedPlaylist)
		return;
	
	NSString *playlistID = [selectedPlaylist valueForKey:@"id"];
	BOOL result = [lastfm addTrack:self.currentTrack byArtist:self.currentArtist toPlaylist:playlistID];
	
	[self displayResultIcon:result];
	
	[playlistPanel orderOut:nil];
	[NSApp endSheet:playlistPanel];
}

- (IBAction)playlistCancel:(id)sender
{
	[playlistPanel orderOut:nil];
	[NSApp endSheet:playlistPanel];
}

- (BOOL)drawerShouldClose:(NSDrawer *)sender
{
	return FALSE;
}

@end
