//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kTwitterTableViewCellIdentifier = @"TwitterTableViewCell";

@interface BOTwitterTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UILabel *tweetLabel;
@property (nonatomic, strong) IBOutlet UILabel *retweetCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *createdAtLabel;

@end