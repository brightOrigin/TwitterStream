//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOTweetModel.h"
#import "NSString+NSDateConversions.h"

@implementation BOTweetModel


- (instancetype) initWithUserName:(NSString *)userName
                            tweet:(NSString *)tweet
                        createdAt:(NSDate *)createdAt
                     retweetCount:(NSNumber *)retweetCount
                          tweetID:(NSNumber *)tweetID
{
    self = [super init];
    if (self)
    {
        self.userName = userName;
        self.tweet = tweet;
        self.createdAt = createdAt;
        self.retweetCount = retweetCount;
        self.tweetID = tweetID;
    }

    return self;
}

- (BOOL) isEqual:(id)other
{
    return [((BOTweetModel *) other).tweetID isEqualToNumber:self.tweetID];
}

@end