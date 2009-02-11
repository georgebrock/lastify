//
//  LastifyDrawerButton.m
//  Lastify
//
//  Created by George on 11/02/2009.
//	Based on code by Matt Gemmell:  http://www.pastebuffer.com/2007/10/04/setting-the-text-color-of-an-nsbutton/
//

#import "NSButton+Lastify.h"


@implementation NSButton (Lastify)

- (void)setTextColor:(NSColor *)textColor
{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    int len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
    [attrTitle release];
}

@end
