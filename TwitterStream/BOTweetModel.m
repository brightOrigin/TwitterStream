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
{
    self = [super init];
    if (self)
    {
        self.userName = userName;
        self.tweet = tweet;
        self.createdAt = createdAt;
        self.retweetCount = retweetCount;
    }

    return self;
}

- (instancetype) initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        if (data)
        {
            NSDictionary *user = [data objectForKey:@"user"];
            if (user)
            {
                self.userName = [user objectForKey:@"screen_name"];
            }

            self.createdAt = [[data objectForKey:@"created_at"] getDateWithFormat:@"EEE MMM d HH:mm:ss Z y"];
            self.tweet = [data objectForKey:@"text"];
            self.retweetCount = [data objectForKey:@"retweet_count"];
        }
    }

    return self;

}

@end