/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "NSObject.h"

@class NSInvocation;

@interface SPInvocationGrabber : NSObject
{
    id _object;
    NSInvocation *_invocation;
    int frameCount;
    char **frameStrings;
}

- (id)initWithObject:(id)fp8;
- (id)initWithObject:(id)fp8 stacktraceSaving:(BOOL)fp12;
- (void)dealloc;
- (id)object;
- (void)setObject:(id)fp8;
- (id)invocation;
- (void)setInvocation:(id)fp8;
- (void)forwardInvocation:(id)fp8;
- (id)methodSignatureForSelector:(SEL)fp8;
- (void)invoke;
- (void)saveBacktrace;
- (void)printBacktrace;

@end

