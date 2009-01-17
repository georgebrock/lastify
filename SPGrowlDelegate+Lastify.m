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
- (void)_original_notificationWithTrackInfo:(void*)info;
@end

@implementation SPGrowlDelegate (Lastify)

+ (void)initLastify
{
	[LastifyController renameSelector:@selector(notificationWithTrackInfo:) toSelector:@selector(_original_notificationWithTrackInfo:) onClass:[self class]];
	[LastifyController renameSelector:@selector(_new_notificationWithTrackInfo:) toSelector:@selector(notificationWithTrackInfo:) onClass:[self class]];
}

- (void)_new_notificationWithTrackInfo:(struct TrackInfo*)info
{
	[self _original_notificationWithTrackInfo:info];
	
	if(info != NULL)
	{
		NSString *songTitle = [NSString stringWithFormat:@"%s", info->_field3];
		
		NSString *dockTitle = [[[[[SPController sharedController] applicationDockMenu:nil] itemArray] objectAtIndex:0] title];
		
		int removeLength = [songTitle length] + 3;
		NSString *artist = [dockTitle stringByReplacingCharactersInRange:NSMakeRange([dockTitle length]-removeLength, removeLength) withString:@""];
		
		NSLog(@"************** LASTIFY track started: \"%@\" by %@", songTitle, artist);
		
		LastifyController *lastify = [LastifyController sharedInstance];
		lastify.currentTrack = songTitle;
		lastify.currentArtist = artist;
	}
}

@end
