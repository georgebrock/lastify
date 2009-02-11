//
//  LastifyDrawerView.m
//  Lastify
//
//  Created by George on 11/02/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import "LastifyDrawerView.h"


@implementation LastifyDrawerView

- (void)drawRect:(NSRect)rect 
{
	[self lockFocus];
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:rect];
	[self unlockFocus];

    [super drawRect:rect];
}

@end
