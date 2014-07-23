//
// Created by Tony Papale on 7/21/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "NSString+NSDateConversions.h"


@implementation NSString (NSDateConversions)

- (NSDate *) getDateWithFormat:(NSString *)dateFormat
{
    if ([self isEqualToString:@""])
    {
        DLog(@"Error formatting date, string is empty!!");
        return nil;
    }

    if ([dateFormat isEqualToString:@""])
    {
        DLog(@"Error formatting date, dateFormat is empty!!");
        return nil;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    Fri Jul 18 18:26:15 +0000 2014
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter dateFromString:self];
}

@end