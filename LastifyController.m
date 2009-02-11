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
	[lastfm authenticate];
}

- (void)loadUserInterface
{
	[NSBundle loadNibNamed:@"LastifyInterface" owner:self];
	
	[loveButton setTextColor:[NSColor whiteColor]];
	[banButton setTextColor:[NSColor whiteColor]];
	[tagButton setTextColor:[NSColor whiteColor]];
	
	[drawer setParentWindow:[[SPController sharedController] mainWindow]];
	NSSize contentSize = NSMakeSize(71, 200);
	[drawer setMaxContentSize:contentSize];
	[drawer setMinContentSize:contentSize];
	[drawer setLeadingOffset:0];
	[drawer setTrailingOffset:0];
	[drawer openOnEdge:NSMaxXEdge];
	[drawer setDelegate:self];
	
	[drawer setContentSize:contentSize];
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

- (IBAction)tagTrack:(id)sender
{
	self.currentTags = [lastfm getTagsForTrack:currentTrack byArtist:currentArtist];
	[tagField setObjectValue:self.currentTags];
	[NSApp beginSheet:tagPanel modalForWindow:[[SPController sharedController] mainWindow] modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)taggingOK:(id)sender
{
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

	if([addTags count] > 0)
	{
		NSLog(@"********** LASTIFY Adding tags: %@", addTags);
		[lastfm addTags:addTags toTrack:currentTrack byArtist:currentArtist];
	}

	if([removeTags count] > 0)
	{
		NSLog(@"********** LASTIFY Removing tags: %@", removeTags);
		[lastfm removeTags:removeTags fromTrack:currentTrack byArtist:currentArtist];
	}

	[removeTags release], removeTags = nil;

	[tagPanel orderOut:nil];
	[NSApp endSheet:tagPanel];
}

- (IBAction)taggingCancel:(id)sender
{
	[tagPanel orderOut:nil];
	[NSApp endSheet:tagPanel];
}

- (BOOL)drawerShouldClose:(NSDrawer *)sender
{
	return FALSE;
}

@end
