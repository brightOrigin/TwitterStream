//
// Created by Tony Papale on 7/21/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOTweetCache.h"
#import <Accounts/Accounts.h>
#import "BOTweetModel.h"
#import "NSString+NSDateConversions.h"
#import "BOTwitterTableViewCell.h"
#import "BOTwitterTableViewCell+ConfigureCell.h"

const NSInteger MAX_TWEETS = 10;

@interface BOTweetCache ()
{
    double startWindowExpirationOffset; // this user defined offset represents the latest time offset that tweets are still valid
}

@property (nonatomic, assign) NSInteger windowSize; // the window size in minutes from the current time
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BOSessionManager *sessionManager;
@property (nonatomic, strong) NSTimer *windowStartTimer;
@property (nonatomic, strong) NSArray *validCachedTweets;
@property (nonatomic, strong) NSMutableDictionary *validCachedTweetsDict;


@end

@implementation BOTweetCache


- (id) initWithWindowSize:(NSInteger)windowSize tableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.windowSize = windowSize;
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.validCachedTweetsDict = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void) resetCacheWithWindowSize:(NSInteger)windowSize
{
    self.windowSize = windowSize;
    self.validCachedTweets = [NSArray array];
    [self.validCachedTweetsDict removeAllObjects];
    [self stopTimer];
    [self.tableView reloadData];
}

- (void) createSessionWithAccount:(ACAccount *)account
{
    NSURL *requestURL = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/sample.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:requestURL
                                               parameters:nil];
    request.account = account;
    self.sessionManager = [[BOSessionManager alloc] initWithRequest:request];
    self.sessionManager.sessionManagerDelegate = self;
}

- (void) toggleStreaming:(BOOL)enabled
{
    [self.sessionManager toggleStreaming:enabled];

    if (enabled)
    {
        [self startTimer];
    }
    else
    {
        [self stopTimer];
    }
}

#pragma mark UITableViewDataSource Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MIN(self.validCachedTweets.count, MAX_TWEETS);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOTwitterTableViewCell *tweetCell = (BOTwitterTableViewCell *) [tableView dequeueReusableCellWithIdentifier:kTwitterTableViewCellIdentifier
                                                                                                   forIndexPath:indexPath];

    BOTweetModel *tweet = [self.validCachedTweets objectAtIndex:indexPath.row];
    [tweetCell configureCell:tweet];

    return tweetCell;
}

#pragma mark BOSessionManagerDelegate Methods

- (void) didReceiveData:(id)data
{
    [self processTweets:data];
}

/**
* This method handles most of the caching by first checking to see if the new tweets retweet count would make
* the top 10. If it would then it adds it to a temp array, incorporates any existing tweets while
* removing any existing duplicates, sorts the array and resets the tables data source to the top 10
**/
- (void) processTweets:(id)newTweetData
{
    NSArray *newTweetsArray;

    if ([newTweetData isKindOfClass:[NSDictionary class]])
    {
        newTweetsArray = [NSArray arrayWithObject:newTweetData];

    }
    else if ([newTweetData isKindOfClass:[NSArray class]])
    {
        newTweetsArray = newTweetData;
    }
    else
    {
        return;
    }

    NSMutableArray *tweetArray = [[NSMutableArray alloc] initWithCapacity:newTweetsArray.count];


    for (NSDictionary *newTweetDict in newTweetsArray)
    {
        NSDictionary *retweetDictionary = [newTweetDict objectForKey:@"retweeted_status"];

        if (retweetDictionary)
        {
            NSDate *retweetDate = [[retweetDictionary objectForKey:@"created_at"]
                                                      getDateWithFormat:@"EEE MMM d HH:mm:ss Z y"];

            if ([retweetDate timeIntervalSince1970] > startWindowExpirationOffset)
            {
                NSNumber *retweetCount = [NSNumber numberWithInt:[[retweetDictionary objectForKey:@"retweet_count"] intValue]];

                // check if retweet count would make the top 10
                if (retweetCount >= ((BOTweetModel *) [self.validCachedTweets lastObject]).retweetCount)
                {

                    NSNumber *tweetID = [NSNumber numberWithInt:[[retweetDictionary objectForKey:@"id"] intValue]];
                    NSString *userName = [[retweetDictionary objectForKey:@"user"] objectForKey:@"screen_name"];
                    NSString *tweet = [retweetDictionary objectForKey:@"text"];

                    if (userName && tweet && retweetCount)
                    {
                        // create new tweet object
                        BOTweetModel *newTweet = [[BOTweetModel alloc] initWithUserName:userName
                                                                                  tweet:tweet
                                                                              createdAt:retweetDate
                                                                           retweetCount:retweetCount
                                                                                tweetID:tweetID];

                        [tweetArray addObject:newTweet];
                    }
                }
            }
        }
    }

    // add existing tweets to array only if it hasn't been updated by a new retweet
    for (BOTweetModel *currentTweet in self.validCachedTweets)
    {
        if (![tweetArray containsObject:currentTweet])
        {
            [tweetArray addObject:currentTweet];
        }
    }

    NSSortDescriptor *count = [[NSSortDescriptor alloc] initWithKey:@"retweetCount" ascending:NO];
    NSSortDescriptor *user = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];

    // sort the new tweets array and return the top 10
    self.validCachedTweets = [[tweetArray sortedArrayUsingDescriptors:@[count, user]]
                                          subarrayWithRange:NSMakeRange(0, MIN(tweetArray.count, MAX_TWEETS))];

    // update table view
    [self.tableView reloadData];
}

#pragma mark Timer Methods

- (void) startTimer
{
    // first stop timer if its already active so we can fire a new request
    if (self.windowStartTimer)
    {
        [self stopTimer];
    }

    __weak BOTweetCache *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // setup new timer
        NSTimer *theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:weakSelf
                                                           selector:@selector(updateStartWindowOffset:)
                                                           userInfo:nil
                                                            repeats:YES];
        weakSelf.windowStartTimer = theTimer;
    });

    // update the start window offset
    startWindowExpirationOffset = [[NSDate dateWithTimeIntervalSinceNow:-(self.windowSize * 60)]
                                           timeIntervalSince1970];

}

/**
* Fired every second by the timer to update the valid tweets in the cache based
* on the specified window size
*/
- (void) updateStartWindowOffset:(NSTimer *)timer
{
    // update the start window offset
    startWindowExpirationOffset = [[NSDate dateWithTimeIntervalSinceNow:-(self.windowSize * 60)]
                                           timeIntervalSince1970];

    // remove any expired tweets
    self.validCachedTweets = [self getValidTweetsFromArray:self.validCachedTweets];

    [self.tableView reloadData];
}

/**
* Prunes the current cache of any tweets that are no longer in the
* rolling window.
*/
- (NSArray *) getValidTweetsFromArray:(NSArray *)tweetsArray
{
    NSMutableArray *validTweets = [NSMutableArray array];

    // remove any expired tweets
    for (BOTweetModel *currentTweet in tweetsArray)
    {
        if ([currentTweet.createdAt timeIntervalSince1970] > startWindowExpirationOffset)
        {
            [validTweets addObject:currentTweet];
        }
    }

    return validTweets;
}

- (void) stopTimer
{
    // check to see if the windowStartTimer has already fired and subsequently invalidated itself
    if (self.windowStartTimer)
    {
        if ([self.windowStartTimer isValid])
        {
            [self.windowStartTimer invalidate];
        }
    }

    self.windowStartTimer = nil;
}

@end