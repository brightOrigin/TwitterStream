//
// Created by Tony Papale on 7/21/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOSessionManager.h"


@interface BOTweetCache : NSObject
        <UITableViewDataSource,
        BOSessionManagerDelegate>

- (id) initWithWindowSize:(NSInteger)windowSize tableView:(UITableView *)tableView;
- (void) resetCacheWithWindowSize:(NSInteger)windowSize;
- (void) createSessionWithAccount:(ACAccount *)account;
- (void) toggleStreaming:(BOOL)enabled;

@end