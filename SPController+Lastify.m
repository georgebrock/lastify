//
//  SPController+Lastify.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
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
