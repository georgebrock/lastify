//
//  NSString+Lastify.m
//  Lastify
//
//  Created by George on 17/01/2009.
//  Copyright 2009 George Brocklehurst. All rights reserved.
//

#import "NSString+Lastify.h"
#include <openssl/md5.h>

@implementation NSString (Lastify)

- (NSString*)MD5Hash
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	if(data) 
	{
		unsigned char *digest = MD5([data bytes], [data length], NULL);
		return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7],
			digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
	}
	
	return nil;
}

@end
