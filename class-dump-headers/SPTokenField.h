/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "NSTokenField.h"

@class NSString;

@interface SPTokenField : NSTokenField
{
    struct PlatformEditBoxOSX *box;
    NSString *autocompleteOutstandingInput;
    struct Array<sp::AutocompleteDelegate::Completion, const sp::AutocompleteDelegate::Completion&, 64, true> autocompleteResult;
}

- (id)initWithFrame:(struct _NSRect)fp8;
- (BOOL)becomeFirstResponder;
- (void)textDidChange:(id)fp8;
- (void)textDidEndEditing:(id)fp8;
- (struct PlatformEditBoxOSX *)platformEditBox;
- (void)setPlatformEditBox:(struct PlatformEditBoxOSX *)fp8;
- (id).cxx_construct;
- (void).cxx_destruct;

@end
