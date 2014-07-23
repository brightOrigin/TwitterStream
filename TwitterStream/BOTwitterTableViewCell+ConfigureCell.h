//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOTwitterTableViewCell.h"

@class BOTweetModel;

@interface BOTwitterTableViewCell (ConfigureCell)

- (void) configureCell:(BOTweetModel *)tweet;

@end