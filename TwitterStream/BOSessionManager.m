//
// Created by Tony Papale on 7/18/14.
// Copyright (c) 2014 Bright Origin. All rights reserved.
//

#import "BOSessionManager.h"

@interface BOSessionManager ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@end

@implementation BOSessionManager

- (id) initWithRequest:(SLRequest *)request
{
    self = [super init];
    if (self)
    {
        NSURLSession *twitterSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                     delegate:self
                                                                delegateQueue:[NSOperationQueue mainQueue]];

        self.sessionDataTask = [twitterSession dataTaskWithRequest:request.preparedURLRequest];
    }

    return self;
}

- (void) toggleStreaming:(BOOL)enabled
{
    if (enabled && self.sessionDataTask.state != NSURLSessionTaskStateRunning)
    {
        [self.sessionDataTask resume];
    }
    else
    {
        [self.sessionDataTask suspend];
    }
}

#pragma mark NSURLSessionDataDelegate Methods

- (void) URLSession:(NSURLSession *)session
           dataTask:(NSURLSessionDataTask *)dataTask
     didReceiveData:(NSData *)data
{

    NSString *tweetData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSInteger intValue = [tweetData integerValue];

    if (intValue > 0) // twitter noise
    {
    }
    else
    {
        NSError *error;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&error];

//        DLog(@"json server response %@", responseDict);
//        DLog(@"error %@", [error localizedDescription]);

        if (responseDict)
        {
            if ([self.sessionManagerDelegate conformsToProtocol:@protocol(BOSessionManagerDelegate)])
            {
                [self.sessionManagerDelegate didReceiveData:responseDict];
            }
        }
    }
}


- (void)  URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"ERROR! didCompleteWithError %@", error.description);
}

@end