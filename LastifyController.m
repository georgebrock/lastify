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

@implementation LastifyController

@synthesize 
	lastfm,
	currentTrack,
	currentArtist;

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
	[super dealloc];
}

- (void)initLastfmConnection
{
	lastfm = [[LastifyLastfmClient alloc] initWithAPIKey:@"aa31898c9c79401a7ddaa6c8f089ccad" APISecret:@"92773b344ec2e14cd6f5780b83c06265"];
	[lastfm authenticate];
}

- (void)loadUserInterface
{
	[NSBundle loadNibNamed:@"LastifyInterface" owner:self];
	[drawer setParentWindow:[[SPController sharedController] mainWindow]];
	NSSize contentSize = NSMakeSize(382, 30);
	[drawer setMaxContentSize:contentSize];
	[drawer setMinContentSize:contentSize];
	[drawer setContentSize:contentSize];
	[drawer setLeadingOffset:10];
	[drawer setTrailingOffset:10];
	[drawer openOnEdge:NSMinYEdge];
	[drawer setDelegate:self];
}

- (IBAction)authComplete:(id)sender
{
	[lastfm startNewSession];
}

- (IBAction)loveTrack:(id)sender
{
	if(!currentTrack || !currentArtist)
		return;

	[lastfm loveTrack:currentTrack byArtist:currentArtist];
}

- (IBAction)banTrack:(id)sender
{
	if(!currentTrack || !currentArtist)
		return;
	
	[lastfm banTrack:currentTrack byArtist:currentArtist];
}

- (BOOL)drawerShouldClose:(NSDrawer *)sender
{
	return FALSE;
}

@end
