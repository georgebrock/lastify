//
//  LastifyLastfmClient.h
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import <Cocoa/Cocoa.h>


@interface LastifyLastfmClient : NSObject 
{
	NSString *APIKey;
	NSString *APISecret;
	NSString *authToken;
	NSString *sessionKey;
	
	BOOL waitingForUserAuth;
	BOOL sessionReady;
}

@property(readwrite, copy) NSString *APIKey;
@property(readwrite, copy) NSString *APISecret;
@property(readwrite, copy) NSString *authToken;
@property(readwrite, copy) NSString *sessionKey;

@property(readwrite, assign) BOOL waitingForUserAuth;
@property(readwrite, assign) BOOL sessionReady;

- (id)initWithAPIKey:(NSString*)newAPIKey APISecret:(NSString*)newSecret;

- (void)authenticate;
- (void)startNewSession;

- (void)loveTrack:(NSString*)trackName byArtist:(NSString*)artistName;
- (void)banTrack:(NSString*)trackName byArtist:(NSString*)artistName;

@end
