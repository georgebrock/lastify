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
- (NSString*)callMethod:(NSString*)methodName withParams:(NSDictionary*)params usingPost:(BOOL)post error:(NSError**)error;
- (void)loadSessionKey;
- (void)storeSessionKey;
@end

@implementation LastifyLastfmClient

@synthesize
	APIKey,
	APISecret,
	authToken,
	sessionKey,
	waitingForUserAuth,
	sessionReady,
	username;
	
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
	[username release], username = nil;
	[super dealloc];
}

- (void)loadSessionKey
{

    SecKeychainSearchRef search;
    SecKeychainItemRef item;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    OSErr result;
	
	attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[self.APIKey UTF8String];
    attributes[0].length = [self.APIKey length];
    
	NSString *itemDescription = @"Lastify Last.fm session information";
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[itemDescription UTF8String];
    attributes[1].length = [itemDescription length];
	
	NSString *itemLabel = @"Lastify Last.fm session information";
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[itemLabel UTF8String];
    attributes[2].length = [itemLabel length];
	
    list.count = 3;
    list.attr = (SecKeychainAttribute*)&attributes;
	
    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
	
    if(result != noErr)
		return;
	
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
				
				NSString *rawLoadedPassword = [NSString stringWithUTF8String:passwordBuffer];
				NSArray *parts = [rawLoadedPassword componentsSeparatedByString:@" / "];
				
				if(parts && [parts count] == 2)
				{
					self.sessionKey = [parts objectAtIndex:0];
					self.username = [parts objectAtIndex:1];
					self.waitingForUserAuth = FALSE;
					self.sessionReady = TRUE;
				}
			}
			
			SecKeychainItemFreeContent(NULL, password);
		}
		
		CFRelease(item);
		CFRelease (search);
	}
}

- (void)storeSessionKey
{
	NSLog(@"In storeSessionKey");
	
	// Create attributes array
	SecKeychainAttribute attributes[3];
	
	// Set the account name (uses the application's consumer key)
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[self.APIKey UTF8String];
    attributes[0].length = [self.APIKey length];
    
	// Set the description
	NSString *itemDescription = @"Lastify Last.fm session information";
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[itemDescription UTF8String];
    attributes[1].length = [itemDescription length];
	
	// Label the item
	NSString *itemLabel = @"Lastify Last.fm session information";
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[itemLabel UTF8String];
    attributes[2].length = [itemLabel length];
	
	// Create list from attributes array
    SecKeychainAttributeList list;
    list.count = 3;
    list.attr = attributes;
	
	// Store the password
	NSString *password = [NSString stringWithFormat:@"%@ / %@", self.sessionKey, self.username];
    SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &list, [password length], [password UTF8String], NULL,NULL,NULL);
}

- (void)authenticateQuietly
{
	[self loadSessionKey];
}

- (void)authenticate
{
	// Attempt to authenticate without user interaction
	[self authenticateQuietly];
	if(self.sessionKey)
		return;
	
	// We need the user to authenticate
	NSString *newAuthToken = [self requestAuthToken];
	
	if(!newAuthToken)
	{
		//TODO: Present an error to the user
		return;
	}
	
	self.authToken = newAuthToken;
	
	// Get the user to authorise the token
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.last.fm/api/auth/?api_key=%@&token=%@", self.APIKey, newAuthToken]]];
	self.waitingForUserAuth = TRUE;
	
	// The authentication will resume with startNewSession when the user has logged in ...
}

- (void)startNewSession
{
	NSError *err = nil;
	NSString *response = [self callMethod:@"auth.getSession" withParams:[NSDictionary dictionaryWithObjectsAndKeys:self.authToken, @"token", nil] usingPost:FALSE error:&err];

	if(err || !response)
	{
		switch([err code])
		{
			case 15: // This token has expired
			case 4: // Invalid authentication token supplied
			case 14: // This token has not been authorized
			case 2: // Invalid service -This service does not exist
			case 3: // Invalid Method - No method with that name in this package
			case 5: // Invalid format - This service doesn't exist in that format
			case 6: // Invalid parameters - Your request is missing a required parameter
			case 7: // Invalid resource specified
			case 9: // Invalid session key - Please re-authenticate
			case 10: // Invalid API key - You must be granted a valid key by last.fm
			case 11: // Service Offline - This service is temporarily offline. Try again later.
			case 12: // Subscribers Only - This service is only available to paid last.fm subscribers
			default:
				break;
		}
		
		return;
	}

	// Extract the username and the session key
	NSString *newSessionKey;
	NSString *newUsername;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	
	[scanner scanUpToString:@"<name>" intoString:NULL];
	[scanner scanString:@"<name>" intoString:NULL];
	[scanner scanUpToString:@"</name>" intoString:&newUsername];
	
	[scanner scanUpToString:@"<key>" intoString:NULL];
	[scanner scanString:@"<key>" intoString:NULL];
	[scanner scanUpToString:@"</key>" intoString:&newSessionKey];
	
	if(!newSessionKey)
	{
		//TODO: Handle this (must be an unexpected error if not caught sooner)
		return;
	}
	
	self.sessionKey = newSessionKey;
	self.username = newUsername;
	self.waitingForUserAuth = FALSE;
	self.sessionReady = TRUE;
	
	[self storeSessionKey];
}

- (NSString*)requestAuthToken
{
	// Request a new auth token from the Last.fm server
	NSError *downloadError = nil;
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=%@", self.APIKey]] encoding:NSUTF8StringEncoding error:&downloadError];
	
	if(downloadError || !response)
	{
		NSLog(@"LASTIFY failed to get Auth Token: %@", downloadError);
		return nil;
	}
	
	NSString *newAuthToken;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	[scanner scanUpToString:@"<token>" intoString:NULL];
	[scanner scanString:@"<token>" intoString:NULL];
	[scanner scanUpToString:@"</token>" intoString:&newAuthToken];
	
	return [[[NSString alloc] initWithString:newAuthToken] autorelease];
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
		NSLog(@"LASTIFY download error: %@", downloadError);
		*error = downloadError;
		return nil;
	}
	
	if([downloadResponse statusCode] != 200)
	{
		NSLog(@"LASTIFY bad HTTP response: %d", [downloadResponse statusCode]);
		
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
	NSLog(@"LASTIFY response: %@", response);
	
	return [response autorelease];
}

- (BOOL)loveTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return FALSE;

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		nil];

	NSError *loveError = nil;
	[self callMethod:@"track.love" withParams:callParams usingPost:TRUE error:&loveError];
	
	return !loveError;
}

- (BOOL)banTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return FALSE;

	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
		trackName, @"track",
		artistName, @"artist",
		nil];

	NSError *banError = nil;
	[self callMethod:@"track.ban" withParams:callParams usingPost:TRUE error:&banError];
	
	return !banError;
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

- (BOOL)addTags:(NSArray*)tags toTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return FALSE;

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
	
	NSError *tagError = nil;
	[self callMethod:@"track.addtags" withParams:callParams usingPost:TRUE error:&tagError];
	
	return !tagError;
}

- (BOOL)removeTags:(NSArray*)tags fromTrack:(NSString*)trackName byArtist:(NSString*)artistName
{
	if(!self.sessionKey)
		return FALSE;
	
	NSString *tag;
	NSDictionary *callParams;
	NSEnumerator *tagEnum = [tags objectEnumerator];
	BOOL result = TRUE;
	while(tag = [tagEnum nextObject])
	{
		callParams = [NSDictionary dictionaryWithObjectsAndKeys:
			trackName, @"track",
			artistName, @"artist",
			tag, @"tag",
			nil];
			
		NSError *tagError = nil;
		[self callMethod:@"track.removetag" withParams:callParams usingPost:TRUE error:&tagError];
		result = result && !tagError;
	}
	
	return result;
}

- (NSArray*)getPlaylists
{
	if(!self.sessionKey)
		return nil;
	
	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
								self.username, @"user",
								nil];
	
	NSString *response = [self callMethod:@"user.getPlaylists" withParams:callParams usingPost:FALSE error:NULL];
	if(!response)
		return nil;
	
	NSMutableArray *playlists = [NSMutableArray arrayWithCapacity:1];
	
	NSScanner *scanner = [NSScanner scannerWithString:response];
	while([scanner scanUpToString:@"<playlist>" intoString:NULL])
	{
		NSString *playlistID;
		[scanner scanUpToString:@"<id>" intoString:NULL];
		[scanner scanString:@"<id>" intoString:NULL];
		BOOL foundID = [scanner scanUpToString:@"</id>" intoString:&playlistID];
		
		NSString *playlistTitle;
		[scanner scanUpToString:@"<title>" intoString:NULL];
		[scanner scanString:@"<title>" intoString:NULL];
		BOOL foundTitle = [scanner scanUpToString:@"</title>" intoString:&playlistTitle];
		
		[scanner scanUpToString:@"</playlist>" intoString:NULL];
		
		if(foundID && foundTitle)
			[playlists addObject:[NSDictionary dictionaryWithObjectsAndKeys:
				playlistID, @"id",
				playlistTitle, @"title",
				nil]];
	}
	
	return (NSArray*)playlists;
}

- (BOOL)addTrack:(NSString*)trackName byArtist:(NSString*)artistName toPlaylist:(NSString*)playlistID
{
	if(!self.sessionKey)
		return FALSE;
	
	NSDictionary *callParams = [NSDictionary dictionaryWithObjectsAndKeys:
								trackName, @"track",
								artistName, @"artist",
								playlistID, @"playlistID",
								nil];
	
	NSError *listError = nil;
	[self callMethod:@"playlist.addTrack" withParams:callParams usingPost:TRUE error:&listError];
	
	return !listError;
}

@end
