//
//  HNPostsTableViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/10/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "HNPostsTableViewController.h"
#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <libHN/libHN.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "HNPostCotentViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <NSAttributedString+CCLFormat/NSAttributedString+CCLFormat.h>
#import "SWRevealViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "constants.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>

@interface HNPostsTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

#pragma mark - view controller life cycle

static const NSString *fontForTableViewLight = @"HelveticaNeue-Light";
static const NSString *fontForTableViewBold = @"HelveticaNeue-Bold";

@implementation HNPostsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpBasicUIComponents];
    //TODO: do something when get new hn posts.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someSelector) name:kHNShouldReloadDataFromConfiguration object:nil];
    
    [[HNManager sharedManager] startSession];
    [self fetchHNPosts];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    NSLog(@"%@", [revealViewController description]);
    if (revealViewController) {
        NSLog(@"hey");
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)setUpBasicUIComponents {
    [self.navigationController.navigationBar setBarTintColor:FlatOrange];
    
    NSDictionary *navigationBarTitleAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:fontForTableViewLight size:17], NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navigationBarTitleAttributes];
    
    UIBarButtonItem *userButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user_icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(pushToUserView)];
    userButton.tintColor = FlatSand;
    self.navigationItem.rightBarButtonItem = userButton;
    self.navigationItem.leftBarButtonItem.tintColor = FlatSand;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self userHasLoggedIn]) {
        //TODO: prepare hn posts content maybe?
        NSLog(@"I'm logged in");
    }else {
        [self performSegueWithIdentifier:@"pop up log in view" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_HNPostsArray count];
}

- (IBAction)refreshHandler:(id)sender {
    [self.refreshControl beginRefreshing];
    [self fetchHNPosts];
    sleep(2);
    [self.refreshControl endRefreshing];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"programmaticCell";
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.delegate = self; //optional
    
    HNPost *post = [_HNPostsArray objectAtIndex:indexPath.row];
    
    //configure left buttons
    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"star_post.png"] backgroundColor:FlatCoffee callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"mark this post as favorite");
        [sender hideSwipeAnimated:YES];
        [self markHNPostAsFavorite:post];
        return YES;
    }]];
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Read" backgroundColor:FlatYellow callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"read this post");
        [sender expandSwipe:MGSwipeDirectionRightToLeft animated:YES];
        [self performSegueWithIdentifier:@"push to hn content view" sender:indexPath];
        return YES;
    }]];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    //get the post
    
    
    //set up ui for title
    cell.textLabel.text = [post Title];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:fontForTableViewLight size:16];
    cell.backgroundColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0];
    cell.swipeBackgroundColor = FlatCoffee;
    
    //set up ui for point and url domain
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    NSString *points = [NSString stringWithFormat:@"%d", [post Points]];
    NSInteger _pointsLength = [points length];
    NSMutableAttributedString *postPoints = [[NSMutableAttributedString alloc] initWithString:points];
    [postPoints addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:fontForTableViewBold
                                             size:14]
                       range:NSMakeRange(0, _pointsLength)];
    
    
    NSString *source = [NSString stringWithFormat:@"%@", [post UrlDomain]];
    NSInteger _sourceLength = [source length];
    NSMutableAttributedString *postSource = [[NSMutableAttributedString alloc] initWithString:source];
    [postSource addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:fontForTableViewLight size:13]
                       range:NSMakeRange(0, _sourceLength)];
    [postSource addAttribute:NSStrokeColorAttributeName
                       value:FlatOrangeDark
                       range:NSMakeRange(0, _sourceLength)];
    [postSource addAttribute:NSStrokeWidthAttributeName
                       value:[NSNumber numberWithFloat:3.0]
                       range:NSMakeRange(0, _sourceLength)];

    NSAttributedString *detailedText = [NSAttributedString attributedStringWithFormat:@"\n%@ \n%@",postPoints, postSource];
    
    cell.detailTextLabel.attributedText = detailedText;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"push to hn content view" sender:indexPath];
}




#pragma mark - Navigation

- (void)pushToUserView {
    [self performSegueWithIdentifier:@"pop up user view" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"push to hn content view"]) {
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        HNPostCotentViewController *HNContentVC = [segue destinationViewController];
        
        NSLog(@"%ld",(long)[indexPath row]);
        HNPost *post = [_HNPostsArray objectAtIndex:[indexPath row]];
        HNContentVC.post = post;
    }
}


#pragma mark - check user login

- (BOOL)userHasLoggedIn {
    return [FBSDKAccessToken currentAccessToken] != nil || ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"password"] != nil);
}

#pragma mark - HN post related (fetch info & mark as favorite)

- (void)fetchHNPosts {
    [[HNManager sharedManager] loadPostsWithFilter:[self determinPostType]
                                        completion:^(NSArray *posts, NSString *nextPageIdentifier) {
                                            if (posts) {
                                                NSLog(@"HN Posts: %lu", (unsigned long)posts.count);
                                                _HNPostsArray = posts;
                                                [self.tableView reloadData];
                                            }else {
                                                NSLog(@"Error fetching post");
                                            }
                                        }];
}

- (void)getMoreHNPosts {
    [[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition]
                                             completion:^(NSArray *posts, NSString *nextPageIdentifier) {
                                                 if (posts) {
                                                     NSLog(@"HN More Posts: %lu", (unsigned long)posts.count);
                                                     _HNPostsArray = posts;
                                                 }else {
                                                     NSLog(@"Error fetching more posts");
                                                 }
                                             }];
}

- (NSInteger)determinPostType {
    NSInteger postType;
    if ([_HNPostType isEqualToString:@"top"]) {
        postType = PostFilterTypeTop;
    }else if ([_HNPostType isEqualToString:@"askHN"]) {
        postType = PostFilterTypeAsk;
    }else if ([_HNPostType isEqualToString:@"jobs"]) {
        postType = PostFilterTypeJobs;
    }else if ([_HNPostType isEqualToString:@"showHN"]) {
        postType = PostFilterTypeShowHN;
    }else if ([_HNPostType isEqualToString:@"new"]) {
        postType = PostFilterTypeNew;
    }else if ([_HNPostType isEqualToString:@"best"]) {
        postType = PostFilterTypeBest;
    }
    return postType;
}

- (void)markHNPostAsFavorite:(HNPost*)post {
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *post_url = [post UrlString];
    NSString *post_url_domain = [post UrlDomain];
    NSString *post_title = [post Title];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:user_id, @"user_id", post_url, @"post_url", post_url_domain, @"post_url_domain", post_title, @"post_title", nil];
    [manager POST:markPostURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"success JSON: %@", responseObject);
              [self handleResponse:responseObject];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failed ERROR: %@", error);
              SCLAlertView *errorAlert = [[SCLAlertView alloc] init];
              [errorAlert showError:@"Error"
                           subTitle:[error localizedDescription]
                   closeButtonTitle:@"OK"
                           duration:0.0f];
          }];
}

// FIXME: SCLAertView doesn't pop up
- (void)handleResponse:(id)response {
    if (response[@"success"]) {
        NSLog(@"here");
        SCLAlertView *successAlert = [[SCLAlertView alloc] init];
        [successAlert showCustom:[UIImage imageNamed:@"default_user_profile_picture"]
                           color:FlatGreen
                           title:@"Success"
                        subTitle:@"Marked this post as favorite successfully!"
                closeButtonTitle:@"OK"
                        duration:0.0f];
    }else {
        NSLog(@"waht");
        SCLAlertView *errorAlert = [[SCLAlertView alloc] init];
        [errorAlert showError:@"Error"
                     subTitle:response[@"error"]
             closeButtonTitle:@"OK"
                     duration:0.0f];
    }
}



@end
