//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOTwitterTableViewCell+ConfigureCell.h"
#import "BOTweetModel.h"
#import "RelativeDateDescriptor.h"

@implementation BOTwitterTableViewCell (ConfigureCell)


- (void) configureCell:(BOTweetModel *)tweet;
{
    self.userLabel.text = [NSString stringWithFormat:@"@%@", tweet.userName];
    self.tweetLabel.text = tweet.tweet;
    self.retweetCountLabel.text = [tweet.retweetCount description];

    RelativeDateDescriptor *descriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago"
                                                                                  postDateDescriptionFormat:@"in %@"];
    self.createdAtLabel.text = [descriptor describeDate:tweet.createdAt relativeTo:[NSDate date]];
}

@end