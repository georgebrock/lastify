//
//  LastifyLastfmClient.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import "LastifyLastfmClient.h"
#import "NSString+Lastify.h"


@implementation LastifyLastfmClient

@synthesize
	APIKey,
	APISecret,
	authToken,
	sessionKey,
	waitingForUserAuth,
	sessionReady;
	
- (id)initWithAPIKey:(NSString*)newAPIKey APISecret:(NSString*)newAPISecret
{
	self = [super init];
	if(!self)
		return nil;
		
	self.APIKey = newAPIKey;
	self.APISecret = newAPISecret;
	
	sessionReady = FALSE;
	waitingForUserAuth = FALSE;
	
	return self;
}

- (void)dealloc
{
	[APIKey release], APIKey = nil;
	[APISecret release], APISecret = nil;
	[authToken release], authToken = nil;
	[sessionKey release], sessionKey = nil;
	[super dealloc];
}

- (NSString*)getAuthToken
{
	// If we've already loaded or fetched the auth token, return it
	if(authToken)
		return authToken;
		
	//TODO: Try to load the auth token from the keychain
	//TODO: If there's one there, check it's authorised by trying to fetch a session key

	// Request a new auth token from the Last.fm server
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=%@", self.APIKey]] encoding:NSUTF8StringEncoding error:NULL];
	
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
	
	// Get the user to authorise the token
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.last.fm/api/auth/?api_key=%@&token=%@", self.APIKey, self.authToken ]]];
	waitingForUserAuth = TRUE;
	
	return authToken;
}

- (void)completeUserAuth
{
	[self getSessionKey];
}

- (NSString*)getSessionKey
{
	if(sessionKey)
		return sessionKey;

	NSString *response = [self callMethod:@"auth.getSession" withParams:[NSDictionary dictionaryWithObjectsAndKeys:authToken, @"token", nil] usingPost:FALSE];

	// Extract the session key
	//TODO: Make this more robust (able to handle errors - in particular a way to go back if the auth token wasn't authorised by the user yet)
	NSString *newSessionKey;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	[scanner scanUpToString:@"<key>" intoString:NULL];
	[scanner scanString:@"<key>" intoString:NULL];
	[scanner scanUpToString:@"</key>" intoString:&newSessionKey];
	
	if(!newSessionKey)
		return nil;
	
	// Retain a copy of the session key
	[self willChangeValueForKey:@"sessionKey"];
	sessionKey = [newSessionKey retain];
	[self didChangeValueForKey:@"sessionKey"];
	
	// Update state
	[self willChangeValueForKey:@"waitingForUserAuth"];
	waitingForUserAuth = FALSE;
	[self didChangeValueForKey:@"waitingForUserAuth"];
	
	[self willChangeValueForKey:@"sessionReady"];
	sessionReady = TRUE;
	[self didChangeValueForKey:@"sessionReady"];

	return sessionKey;
}
	
- (NSString*)callMethod:(NSString*)methodName withParams:(NSDictionary*)params usingPost:(BOOL)post
{
	NSMutableString *urlString = [NSMutableString stringWithString:@"http://ws.audioscrobbler.com/2.0/"];
	
	// Add the standard parameters (methodName, APIKey)
	NSMutableDictionary *mutableParams = [params mutableCopy];
	[mutableParams setObject:self.APIKey forKey:@"api_key"];
	[mutableParams setObject:methodName forKey:@"method"];
	
	// If we have a session key, add it to the parameters
	if(sessionKey)
		[mutableParams setObject:sessionKey forKey:@"sk"];
	
	// Sort the params alphabetically
	NSArray *sortedKeys = [[mutableParams allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	// Add the parameters to the signature base and the URL string
	NSMutableString *signatureBase = [NSMutableString stringWithCapacity:50];
	NSMutableString *queryString = [NSMutableString stringWithCapacity:50];
	
	NSEnumerator *paramEnumerator = [sortedKeys objectEnumerator];
	NSString *key, *value, *escapedValue;
	while(key = [paramEnumerator nextObject])
	{
		value = [mutableParams objectForKey:key];
		[signatureBase appendFormat:@"%@%@", key, value];
		
		escapedValue = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, NULL, (CFStringRef)@"&=:/,", kCFStringEncodingUTF8);
		[queryString appendFormat:@"%@=%@&", key, escapedValue];
		CFRelease(escapedValue), escapedValue = nil;
	}
	
	// Generate the signature
	[signatureBase appendString:self.APISecret];
	[queryString appendFormat:@"api_sig=%@", [signatureBase MD5Hash]];
	
	// Tidy up
	[mutableParams release], mutableParams = nil;
	
	// Build the request
	NSURLRequest *urlReq;
	if(post)
	{
		NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[postRequest setHTTPMethod:@"POST"];
		[postRequest setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
		urlReq = postRequest;
	}
	else
	{
		[urlString appendFormat:@"?%@", queryString];
		urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	}
	
	// Call the Last.fm API
	NSHTTPURLResponse *downloadResponse;
	NSError *downloadError;
	NSData *downloadData;
	downloadData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&downloadResponse error:&downloadError];
	
	// Check for errors in the response
	if(downloadError)
	{
		NSLog(@"************** LASTIFY download error: %@", downloadError);
		return nil;
	}
	
	if([downloadResponse statusCode] != 200)
	{
		NSLog(@"************** LASTIFY bad HTTP response: %d", [downloadResponse statusCode]);
		return nil;
	}
	
	// Extract the string from the response
	NSString *response = [[NSString alloc] initWithData:downloadData encoding:NSUTF8StringEncoding];
	NSLog(@"************** LASTIFY response: %@", response);
	
	return [response autorelease];
}

- (void)loveTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return;

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		nil];

	NSString *response = [self callMethod:@"track.love" withParams:callParams usingPost:TRUE];
		
	NSLog(@"***** LASTIFY: Love track response %@", response);
}

- (void)banTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return;

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		nil];

	[self callMethod:@"track.ban" withParams:callParams usingPost:TRUE];
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
	// http://ws.audioscrobbler.com/2.0/?api_key=aa31898c9c79401a7ddaa6c8f089ccad&method=auth.getSession&token=6a0953be472918be417de435dd4b72e9&api_sig=...
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