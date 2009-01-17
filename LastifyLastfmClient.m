//
//  LastifyLastfmClient.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import "LastifyLastfmClient.h"


@implementation LastifyLastfmClient

@synthesize
	APIKey,
	authToken;
	
- (id)initWithAPIKey:(NSString*)newAPIKey
{
	self = [super init];
	if(!self)
		return nil;
		
	self.APIKey = newAPIKey;
	
	// Try to load the auth token from the keychain
	// If it's not there, get one from the server and ask the user too authenticate
	
	return self;
}

- (void)dealloc
{
	[APIKey release], APIKey = nil;
	[authToken release], authToken = nil;
	[super dealloc];
}

- (NSString*)getAuthToken
{
	if(authToken)
		return authToken;

	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=%@", self.APIKey]]];
	NSLog(@"%@", response);
	
	NSString *newAuthToken;
	
	NSScanner *scanner = [NSScanner scannerWithString:response];
	[scanner scanUpToString:@"<token>" intoString:NULL];
	[scanner scanString:@"<token>" intoString:NULL];
	[scanner scanUpToString:@"</token>" intoString:&newAuthToken];

	if(!newAuthToken)
		return nil;

	[self willChangeValueForKey:@"authToken"];
	authToken = [[NSString alloc] initWithString:newAuthToken];
	[self didChangeValueForKey:@"authToken"];
	
	return authToken;
}
	
- (void)callMethod:(NSString*)methodName withParams:(NSDictionary*)params
{
}

@end


// AUTHENTICATION FLOW

// API key: aa31898c9c79401a7ddaa6c8f089ccad
//  secret: 92773b344ec2e14cd6f5780b83c06265

// To authorise:
	
	// Get a token
	// http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=aa31898c9c79401a7ddaa6c8f089ccad
	// e.g. Token: 6a0953be472918be417de435dd4b72e9
	
	// Ask the user to authorise the token
	// http://www.last.fm/api/auth/?api_key=aa31898c9c79401a7ddaa6c8f089ccad&token=6a0953be472918be417de435dd4b72e9
	
// Once we're authorised:

	// Get a session key
	// http://ws.audioscrobbler.com/2.0/?api_key=aa31898c9c79401a7ddaa6c8f089ccad&method=auth.getSession&token=6a0953be472918be417de435dd4b72e9&spi_sig=...
		// api_sig: sort other query string keys/values alphabetically and do md5(key1val1key2val2...secret)

// Call methods:

	// Love a track
	// http://ws.audioscrobbler.com/2.0/?
	//	api_key=aa31898c9c79401a7ddaa6c8f089ccad&
	//	method=track.love&
	//	track=<trackname>&
	//	artist=<artist>&
	//	api_sig=<api_sig>&
	//  sk=<session_key>
	
	// Ban a track
	// http://ws.audioscrobbler.com/2.0/?
	//	api_key=aa31898c9c79401a7ddaa6c8f089ccad&
	//	method=track.ban&
	//	track=<trackname>&
	//	artist=<artist>&
	//	api_sig=<api_sig>&
	//  sk=<session_key>
