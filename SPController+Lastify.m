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
- (void)_original_setupWindowAndViews;
@end

@implementation SPController (Lastify)

+ (void)initLastify
{
	[LastifyController renameSelector:@selector(setupWindowAndViews) toSelector:@selector(_original_setupWindowAndViews) onClass:[self class]];
	[LastifyController renameSelector:@selector(_new_setupWindowAndViews) toSelector:@selector(setupWindowAndViews) onClass:[self class]];
}

- (void)_new_setupWindowAndViews
{
	[self _original_setupWindowAndViews];
	[[LastifyController sharedInstance] loadUserInterface];
}

@end
