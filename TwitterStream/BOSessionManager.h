//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>

@protocol BOSessionManagerDelegate <NSObject>

- (void) didReceiveData:(id)data;

@end

@interface BOSessionManager : NSObject
        <NSURLSessionDelegate,
        NSURLSessionDataDelegate>

@property (nonatomic, weak) id <BOSessionManagerDelegate> sessionManagerDelegate;

- (id) initWithRequest:(SLRequest *)request;
- (void) toggleStreaming:(BOOL)enabled;

@end

