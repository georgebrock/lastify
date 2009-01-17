//
//  LastifyLastfmClient.h
//  Lastify
//
//  Created by George on 16/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LastifyLastfmClient : NSObject 
{
	NSString *APIKey;
	NSString *authToken;
}

@property(readwrite, retain) NSString *APIKey;
@property(readwrite, retain, getter=getAuthToken) NSString *authToken;

- (id)initWithAPIKey:(NSString*)newAPIKey;
- (void)callMethod:(NSString*)methodName withParams:(NSDictionary*)params;

@end
