//
//  LastifyController.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import <objc/objc-class.h>
#import "LastifyController.h"

@implementation LastifyController

+ (void)load
{
	LastifyController *controller = [LastifyController sharedInstance];
	[controller loadUserInterface];
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


- (void)loadUserInterface
{
	NSLog(@"***** LASTIFY: Load user interface");
	NSLog(@"%@", [NSApp mainWindow]);

	[NSBundle loadNibNamed:@"LastifyInterface" owner:self];
	[drawer setParentWindow:[NSApp mainWindow]];
	[drawer open:self];
}

- (IBAction)loveTrack:(id)sender
{
	NSLog(@"***** LASTIFY: Love track");
}

- (IBAction)banTrack:(id)sender
{
	NSLog(@"***** LASTIFY: Ban track");
}

@end
