//
//  LastifyLastfmClient.m
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2008 George Brocklehurst. Some rights reserved (see accompanying LICENSE file for details).
//

#import "LastifyLastfmClient.h"
#import "NSString+Lastify.h"


@interface LastifyLastfmClient (Private)
- (NSString*)requestAuthToken;
- (NSString*)requestSessionKey;
- (NSString*)callMethod:(NSString*)methodName withParams:(NSDictionary*)params usingPost:(BOOL)post error:(NSError**)error;
- (NSString*)loadAuthTokenFromKeychain;
- (void)storeAuthTokenInKeychain:(NSString*)newAuthToken;
@end

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

- (void)authenticateQuietly
{
	NSString *loadedAuthToken = [self loadAuthTokenFromKeychain];
	if(!loadedAuthToken)
		return;
		
	self.authToken = loadedAuthToken;
	[self startNewSession];
}

- (void)authenticate
{
	NSString *loadedAuthToken = [self loadAuthTokenFromKeychain];

	if(loadedAuthToken)
	{
		self.authToken = loadedAuthToken;
		[self startNewSession];
		//TODO: Handle issues with new session tokens
		return;
	}

	// Get a new token
	NSString *newAuthToken = [self requestAuthToken];
	
	if(!newAuthToken)
	{
		//TODO: Handle this
		return;
	}
	
	// Store the auth token
	self.authToken = newAuthToken;
	[self storeAuthTokenInKeychain:newAuthToken];
	
	// Get the user to authorise the token
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.last.fm/api/auth/?api_key=%@&token=%@", self.APIKey, newAuthToken ]]];
	self.waitingForUserAuth = TRUE;
	
	// The authentication will resume with completeUserAuth when the user has logged in ...
	return;
}

- (void)startNewSession
{
	NSString *newSessionKey = [self requestSessionKey];
	
	if(!newSessionKey)
	{
		//TODO: Handle this (what to do depends on the error)
		return;
	}
	
	self.sessionKey = newSessionKey;
	
	self.waitingForUserAuth = FALSE;
	self.sessionReady = TRUE;
}

- (NSString*)loadAuthTokenFromKeychain
{
	NSString *loadedAuthToken = nil;

    SecKeychainSearchRef search;
    SecKeychainItemRef item;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    OSErr result;

	attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[self.APIKey UTF8String];
    attributes[0].length = [self.APIKey length];
    
	NSString *itemDescription = @"Lastify Last.fm access token";
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[itemDescription UTF8String];
    attributes[1].length = [itemDescription length];
	
	NSString *itemLabel = @"Lastify Last.fm access token";
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[itemLabel UTF8String];
    attributes[2].length = [itemLabel length];

    list.count = 3;
    list.attr = (SecKeychainAttribute*)&attributes;

    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);

    if(result != noErr)
		return nil;
	
    if(SecKeychainSearchCopyNext(search, &item) == noErr) 
	{
		UInt32 length;
		char *password;
		OSStatus status;
											 
		status = SecKeychainItemCopyContent(item, NULL, NULL, &length, (void **)&password);
		
		if(status == noErr) 
		{
			if (password != NULL) 
			{
				char passwordBuffer[length+1];
				strncpy(passwordBuffer, password, length);
				passwordBuffer[length] = '\0';
				
				loadedAuthToken = [NSString stringWithUTF8String:passwordBuffer];
			}

			SecKeychainItemFreeContent(NULL, password);
		}

		CFRelease(item);
		CFRelease (search);
	}
	
	return loadedAuthToken;
}

- (void)storeAuthTokenInKeychain:(NSString*)newAuthToken
{
	// Create attributes array
	SecKeychainAttribute attributes[3];
	
	// Set the account name (uses the application's consumer key)
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[self.APIKey UTF8String];
    attributes[0].length = [self.APIKey length];
    
	// Set the description
	NSString *itemDescription = @"Lastify Last.fm access token";
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[itemDescription UTF8String];
    attributes[1].length = [itemDescription length];
	
	// Label the item
	NSString *itemLabel = @"Lastify Last.fm access token";
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[itemLabel UTF8String];
    attributes[2].length = [itemLabel length];

	// Create list from attributes array
    SecKeychainAttributeList list;
    list.count = 3;
    list.attr = attributes;

	// Store the password
    SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &list, [self.authToken length], [self.authToken UTF8String], NULL,NULL,NULL);
}

- (NSString*)requestAuthToken
{
	// Request a new auth token from the Last.fm server
	NSError *downloadError = nil;
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=%@", self.APIKey]] encoding:NSUTF8StringEncoding error:&downloadError];
	
	if(downloadError || !response)
	{
		NSLog(@"************** LASTIFY failed to get Auth Token: %@", downloadError);
		return nil;
	}
	
	NSString *newAuthToken;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	[scanner scanUpToString:@"<token>" intoString:NULL];
	[scanner scanString:@"<token>" intoString:NULL];
	[scanner scanUpToString:@"</token>" intoString:&newAuthToken];
	
	return [[[NSString alloc] initWithString:newAuthToken] autorelease];
}

- (NSString*)requestSessionKey
{
	NSString *response = [self callMethod:@"auth.getSession" withParams:[NSDictionary dictionaryWithObjectsAndKeys:self.authToken, @"token", nil] usingPost:FALSE error:NULL];

	if(!response)
		return nil;

	// Extract the session key
	NSString *newSessionKey;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	[scanner scanUpToString:@"<key>" intoString:NULL];
	[scanner scanString:@"<key>" intoString:NULL];
	[scanner scanUpToString:@"</key>" intoString:&newSessionKey];

	return [[[NSString alloc] initWithString:newSessionKey] autorelease];
}
	
- (NSString*)callMethod:(NSString*)methodName withParams:(NSDictionary*)params usingPost:(BOOL)post error:(NSError**)error
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
		*error = downloadError;
		return nil;
	}
	
	if([downloadResponse statusCode] != 200)
	{
		NSLog(@"************** LASTIFY bad HTTP response: %d", [downloadResponse statusCode]);
		
		if(downloadData)
		{
			NSString *errorResponse = [[NSString alloc] initWithData:downloadData encoding:NSUTF8StringEncoding];

			NSInteger errNo;
			NSString *errMsg;
			NSScanner *errScanner = [NSScanner scannerWithString:errorResponse];
			[errScanner scanUpToString:@"<error code=\"" intoString:NULL];
			[errScanner scanString:@"<error code=\"" intoString:NULL];
			[errScanner scanInteger:&errNo];
			[errScanner scanUpToString:@">" intoString:NULL];
			[errScanner scanString:@">" intoString:NULL];
			[errScanner scanUpToString:@"</error>" intoString:&errMsg];
			
			if(errMsg && errNo)
			{
				*error = [NSError 
					errorWithDomain:@"com.georgebrock.lastify"
					code:errNo
					userInfo:[NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey]];
			}
			
			[errorResponse release], errorResponse = nil;
		}
		
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

	[self callMethod:@"track.love" withParams:callParams usingPost:TRUE error:NULL];
}

- (void)banTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return;

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		nil];

	[self callMethod:@"track.ban" withParams:callParams usingPost:TRUE error:NULL];
}

- (NSArray*)getTagsForTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return nil;

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		nil];

	NSString *response = [self callMethod:@"track.gettags" withParams:callParams usingPost:FALSE error:NULL];
	if(!response)
		return nil;
	
	NSMutableArray *tags = [NSMutableArray arrayWithCapacity:1];
	
	NSString *newTag;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	while([scanner scanUpToString:@"<name>" intoString:NULL])
	{
		[scanner scanString:@"<name>" intoString:NULL];
		if([scanner scanUpToString:@"</name>" intoString:&newTag])
			[tags addObject:newTag];
	}
	
	return (NSArray*)tags;
}

- (void)addTags:(NSArray*)tags toTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return;

	if([tags count] > 10)
	{
		NSArray *remainder = [tags subarrayWithRange:NSMakeRange(10, [tags count]-10)];
		[self addTags:remainder toTrack:trackName byArtist:artistName];
		
		tags = [tags subarrayWithRange:NSMakeRange(0, 10)];
	}

	NSString *tagString = [tags componentsJoinedByString:@","];

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		tagString, @"tags",
		nil];
		
	[self callMethod:@"track.addtags" withParams:callParams usingPost:TRUE error:NULL];
}

- (void)removeTags:(NSArray*)tags fromTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return;
	
	NSString *tag;
	NSDictionary *callParams;
	NSEnumerator *tagEnum = [tags objectEnumerator];
	while(tag = [tagEnum nextObject])
	{
		callParams = [NSDictionary dictionaryWithObjectsAndKeys:
			trackName, @"track",
			artistName, @"artist",
			tag, @"tag",
			nil];
			
		[self callMethod:@"track.removetag" withParams:callParams usingPost:TRUE error:NULL];
	}
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
