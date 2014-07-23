//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BOTweetModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *tweet;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) NSNumber *retweetCount;


- (instancetype) initWithUserName:(NSString *)userName
                            tweet:(NSString *)tweet
                        createdAt:(NSDate *)createdAt
                     retweetCount:(NSNumber *)retweetCount;

- (instancetype) initWithDictionary:(NSDictionary *)data;

@end