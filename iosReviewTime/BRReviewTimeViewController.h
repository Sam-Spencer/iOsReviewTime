//
//  BRReviewTimeViewController.h
//  iosReviewTime
//
//  Created by iRare Media on 12/20/13.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

@interface BRReviewTimeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *requestData;
@property (strong, nonatomic) NSURL *apiURL;
@property (strong, nonatomic) NSMutableArray *results;

@property (strong, nonatomic) NSDecimalNumber *tweetsCount;
@property (strong, nonatomic) NSMutableArray *tableViewCells;

- (BOOL)userHasAccessToTwitter;
- (void)displayNoTwitterError;

- (IBAction)refreshTweets:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *reviewTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end
