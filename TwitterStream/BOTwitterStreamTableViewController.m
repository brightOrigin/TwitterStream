//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOTwitterStreamTableViewController.h"
#import <Accounts/Accounts.h>
#import "BOTwitterTableViewCell.h"
#import "BOTweetCache.h"


@interface BOTwitterStreamTableViewController ()
{
    BOOL streaming;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BOTweetCache *tweetCache;
@property (nonatomic, strong) UIBarButtonItem *startStopButton;
@property (nonatomic, strong) ACAccount *twitterAccount;

@end


@implementation BOTwitterStreamTableViewController

- (void) loadView
{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             [UIScreen mainScreen].bounds.size.width,
                                                             [UIScreen mainScreen].bounds.size.height)];
    aView.backgroundColor = [UIColor darkGrayColor];
    self.view = aView;
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Most Retweeted", nil);

    [self setupTableView];
    [self setupNavBarItems];
}

- (void) setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   64,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - 64)
                                                  style:UITableViewStylePlain];
    self.tableView.rowHeight = 140;
//    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"BOTwitterTableViewCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kTwitterTableViewCellIdentifier];

    [self.view addSubview:self.tableView];
}

- (void) setupNavBarItems
{
    self.startStopButton = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"Start", nil)
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(startStopTapped:)];

    self.navigationItem.rightBarButtonItem = self.startStopButton;
}


- (void) setupTwitterSessionWithWindowSize:(NSInteger)windowSize
{

    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    // Get the request access from the user.
    [twitterStore requestAccessToAccountsWithType:twitterAccountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error) {

        if (!granted)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"We need access to your twitter account so we can contact twitter. Please enable access in Settings > Twitter", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {

            // Grab the available accounts
            NSArray *twitterAccounts = [twitterStore accountsWithAccountType:twitterAccountType];

            if ([twitterAccounts count] > 0)
            {
                self.twitterAccount = [twitterAccounts lastObject];

                if (!self.tweetCache)
                {
                    // init cache & create session
                    self.tweetCache = [[BOTweetCache alloc] initWithWindowSize:windowSize tableView:self.tableView];
                    [self.tweetCache createSessionWithAccount:self.twitterAccount];
                }
                else
                {
                    [self.tweetCache resetCacheWithWindowSize:windowSize];
                }

                [self.tweetCache toggleStreaming:YES];

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.startStopButton.title = NSLocalizedString(@"Stop", nil);
                });

                streaming = YES;
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log In To Twitter", nil)
                                                                    message:NSLocalizedString(@"Please sign in to your twitter account via Settings > Twitter", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];

}

- (void) startStopTapped:(id)sender
{

    if (streaming)
    {
        [self.tweetCache toggleStreaming:FALSE];
        self.startStopButton.title = NSLocalizedString(@"Start", nil);
        streaming = NO;
    }
    else
    {
        [self minutePrompt];
    }
}

- (void) minutePrompt
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(@"Please enter the number of mins into the past you want to view", nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alert textFieldAtIndex:0] becomeFirstResponder];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {

        int windowSize = [[[alertView textFieldAtIndex:0] text] intValue];

        // lazy load the session
        if (!self.twitterAccount)
        {
            [self setupTwitterSessionWithWindowSize:windowSize];
        }
        else
        {
            [self.tweetCache resetCacheWithWindowSize:windowSize];
            [self.tweetCache toggleStreaming:YES];
            self.startStopButton.title = NSLocalizedString(@"Stop", nil);
            streaming = YES;
        }
    }
}

@end