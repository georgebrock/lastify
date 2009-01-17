//
//  LastifyController.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import <objc/objc-class.h>
#import "LastifyController.h"
#import "SPController.h"
#import "SPController+Lastify.h"

@implementation LastifyController

+ (void)load
{
	[SPController initLastify];
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
	[super dealloc];
}

- (void)initLastfmConnection
{
	lastfm = [[LastifyLastfmClient alloc] initWithAPIKey:@"aa31898c9c79401a7ddaa6c8f089ccad"];
	NSLog(@"******* LASTIFY: %@", lastfm.authToken);
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

- (IBAction)loveTrack:(id)sender
{
	NSLog(@"***** LASTIFY: Love track");
}

- (IBAction)banTrack:(id)sender
{
	NSLog(@"***** LASTIFY: Ban track");
}

- (BOOL)drawerShouldClose:(NSDrawer *)sender
{
	return FALSE;
}

@end
