//
//  SPGrowlDelegate+Lastify.m
//  Lastify
//
//  Created by George on 17/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import "SPGrowlDelegate+Lastify.h"
#import "SPController.h"
#import "LastifyController.h"
#import "SPTypes.h"


@interface SPGrowlDelegate (DummyReplacedMethods)
- (void)_lastify_notificationWithTrackInfo:(void*)info;
@end

@implementation SPGrowlDelegate (Lastify)

+ (void)initLastify
{
	[LastifyController swapMethod:@selector(notificationWithTrackInfo:) withMethod:@selector(_lastify_notificationWithTrackInfo:) onClass:[self class]];
}

- (void)_lastify_notificationWithTrackInfo:(struct TrackInfo*)info
{
	[self _lastify_notificationWithTrackInfo:info];
	
	if(info != NULL)
	{
		NSString *songTitle = [[NSString alloc] initWithCString:info->_field3 encoding:NSUTF8StringEncoding];
		
		NSString *dockTitle = [[[[[SPController sharedController] applicationDockMenu:nil] itemArray] objectAtIndex:0] title];
		
		int removeLength = [songTitle length] + 3;
		NSString *artist = [dockTitle stringByReplacingCharactersInRange:NSMakeRange([dockTitle length]-removeLength, removeLength) withString:@""];
		
		[[LastifyController sharedInstance] startNewTrack:songTitle byArtist:artist];
		
		[songTitle release], songTitle = nil;
	}
}

@end
