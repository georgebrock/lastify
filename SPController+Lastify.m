//
//  SPController+Lastify.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import "SPController+Lastify.h"
#import "LastifyController.h"


@interface SPController (DummyReplacedMethods)
- (void)_lastify_setupWindowAndViews;
@end

@implementation SPController (Lastify)

+ (void)initLastify
{
	[LastifyController swapMethod:@selector(setupWindowAndViews) withMethod:@selector(_lastify_setupWindowAndViews) onClass:[self class]];
}

- (void)_lastify_setupWindowAndViews
{
	[self _lastify_setupWindowAndViews];
	[[LastifyController sharedInstance] loadUserInterface];
}

@end
