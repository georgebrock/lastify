//
//  LastifyLastfmClient.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
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
	// If we've already loaded or fetched the auth token, return it
	if(authToken)
		return authToken;
		
	//TODO: Try to load the auth token from the keychain
	//TODO: Test it by trying to fetch a session key

	// Request a new auth token from the Last.fm server
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=%@", self.APIKey]]];
	
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
	
	//TODO: Stash the auth token in the keychain
	
	//TODO: Get the user to authorise the token
	//TODO: When the user has authorised the token, check it by trying to fetch a session key
	
	return authToken;
}
	
- (void)callMethod:(NSString*)methodName withParams:(NSDictionary*)params
{
	NSMutableString *urlString = [NSMutableString stringWithString:@"http://ws.audioscrobbler.com/2.0/?"];
	
	//TODO: Add the standard parameters (methodName, APIKey)
	
	//TODO: If we have a session key, add it to the parameters
	
	//TODO: Sort the params alphabetically
	
	//TODO: Add the parameters to the URL string
	
	//TODO: Generate the signature
	
	//TODO: Add the signature to the URL string
	
	//TODO: Call the method
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
