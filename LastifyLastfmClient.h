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

@property(readwrite, retain) NSString *APIKey;
@property(readwrite, retain) NSString *APISecret;
@property(readwrite, retain, getter=getAuthToken) NSString *authToken;
@property(readwrite, retain, getter=getSessionKey) NSString *sessionKey;

@property(readonly, assign) BOOL waitingForUserAuth;
@property(readonly, assign) BOOL sessionReady;

- (id)initWithAPIKey:(NSString*)newAPIKey APISecret:(NSString*)newSecret;
- (NSString*)callMethod:(NSString*)methodName withParams:(NSDictionary*)params usingPost:(BOOL)post;
- (void)completeUserAuth;

- (void)loveTrack:(NSString*)trackName byArtist:(NSString*)artistName;
- (void)banTrack:(NSString*)trackName byArtist:(NSString*)artistName;

@end
