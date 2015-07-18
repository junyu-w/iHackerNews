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
#import <JFMinimalNotifications/JFMinimalNotification.h>
#import <BubbleTransition-objc/YPBubbleTransition.h>

@interface HNPostsTableViewController () <UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIBarButtonItem *userButton;
@property (nonatomic, strong) YPBubbleTransition *transition;
@end

#pragma mark - view controller life cycle

@implementation HNPostsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpBasicUIComponents];
    //TODO: do something when get new hn posts.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someSelector) name:kHNShouldReloadDataFromConfiguration object:nil];
    
    if ([_HNPostType isEqualToString:@"favorites"]) {
        [self getDifferentDatesOfPosts];
        [self getFavoritePosts];
    }else {
        [self fetchHNPosts];
    }
    
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
    
    self.userButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user_icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(pushToUserView)];
    self.userButton.tintColor = FlatSand;
    self.navigationItem.rightBarButtonItem = self.userButton;
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
    if ([_HNPostType isEqualToString:@"favorites"]) {
        return [_differentDates count];
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_differentDates objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([_HNPostType isEqualToString:@"favorites"]) {
        NSString *date = [_differentDates objectAtIndex:section];
        return [[_favoritePosts objectForKey:date] count];
    }
    return [_HNPostsArray count];
}

- (IBAction)refreshHandler:(id)sender {
    [self.refreshControl beginRefreshing];
    if ([_HNPostType isEqualToString:@"favorites"]) {
        [self getFavoritePosts];
    }else {
        [self fetchHNPosts];
    }
    [self.refreshControl endRefreshing];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"programmaticCell";
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.delegate = self; //optional
    
    HNPost *post;
    NSMutableDictionary *favoritePost;
    if ([_HNPostType isEqualToString:@"favorites"]) {
        //favoritePost = [_favoritePosts objectAtIndex:indexPath.row];
        NSString *date = [_differentDates objectAtIndex:indexPath.section];
        favoritePost = [[_favoritePosts objectForKey:date] objectAtIndex:indexPath.row];
    }else {
        post = [_HNPostsArray objectAtIndex:indexPath.row];
    }

    
    //configure left buttons
    if ([_HNPostType isEqualToString:@"favorites"]) {
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Remove" backgroundColor:FlatRed callback:^BOOL(MGSwipeTableCell *sender) {
            NSString *date = [_differentDates objectAtIndex:indexPath.section];
            NSMutableArray *favoritePostsOnDate = (NSMutableArray *) [_favoritePosts objectForKey:date];
            [self unmarkPost:[favoritePostsOnDate objectAtIndex:indexPath.row] atIndexPath:indexPath];
            return YES;
        }]];
    }else {
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
    }
    
    NSString *points; //only for non-favorite post type
    NSString *source;
    NSMutableAttributedString *postPoints;
    
    if ([_HNPostType isEqualToString:@"favorites"]) {
        // set up ui for favorite posts
        cell.textLabel.text = favoritePost[@"title"];
        source = favoritePost[@"urlDomain"];
    }else {
        //set up ui for non-favorite posts
        cell.textLabel.text = [post Title];
        source = [NSString stringWithFormat:@"%@", [post UrlDomain]];
        points = [NSString stringWithFormat:@"%d", [post Points]];
        NSInteger _pointsLength = [points length];
        postPoints = [[NSMutableAttributedString alloc] initWithString:points];
        [postPoints addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:fontForTableViewBold
                                                 size:14]
                           range:NSMakeRange(0, _pointsLength)];

    }
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:fontForTableViewLight size:16];
    cell.backgroundColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0];
    cell.swipeBackgroundColor = FlatCoffee;
    
    //set up ui url domain
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    
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
    
    NSAttributedString *detailedText;
    if ([_HNPostType isEqualToString:@"favorites"]) {
        detailedText = [NSAttributedString attributedStringWithFormat:@"\n%@",postSource];
    }else {
        detailedText = [NSAttributedString attributedStringWithFormat:@"\n%@ \n%@",postPoints, postSource];
    }
    cell.detailTextLabel.attributedText = detailedText;
    
    // when scroll to the bottom of the table, load more data
    if (indexPath.row == [_HNPostsArray count]-1) {
        [self getMoreHNPosts];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"push to hn content view" sender:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
        if ([_HNPostType isEqualToString:@"favorites"]) {
            NSLog(@"%ld",(long)[indexPath row]);
            NSMutableDictionary *favoritePost = [[_favoritePosts objectForKey:[_differentDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            NSLog(@"favorite post JSON: %@", favoritePost);
            HNContentVC.favoritePost = favoritePost;
        }else {
            NSLog(@"%ld",(long)[indexPath row]);
            HNPost *post = [_HNPostsArray objectAtIndex:[indexPath row]];
            HNContentVC.post = post;
        }
    }else if ([[segue identifier] isEqualToString:@"pop up user view"]) {
        UIViewController *userView = [segue destinationViewController];
        userView.transitioningDelegate = self;
        userView.modalPresentationStyle = UIModalPresentationCustom;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)
presenting sourceController:(UIViewController *)source {
    self.transition.transitionMode = YPBubbleTransitionModePresent;
    
    self.transition.startPoint = CGPointMake(self.view.frame.size.width-35, 35);
    self.transition.bubbleColor = FlatWhite;
    self.transition.duration = 0.5;
    
    return self.transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transition.transitionMode = YPBubbleTransitionModeDismiss;
    
    self.transition.startPoint = CGPointMake(self.view.frame.size.width-35, 35);
    self.transition.bubbleColor = FlatWhite;
    self.transition.duration = 0.5;
    
    return self.transition;
}

-(YPBubbleTransition *)transition
{
    if (!_transition) {
        _transition = [[YPBubbleTransition alloc] init];
    }
    return _transition;
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
                                                _HNPostsArray = (NSMutableArray *) posts;
                                                [self.tableView reloadData];
                                            }else {
                                                NSLog(@"Error fetching post");
                                            }
                                        }];
}

// getting more hacker news posts by incrementing pages
- (void)getMoreHNPosts {
    [[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition]
                                             completion:^(NSArray *posts, NSString *nextPageIdentifier) {
                                                 if (posts) {
                                                     NSLog(@"HN More Posts: %lu", (unsigned long)posts.count);
                                                     NSLog(@"%@", [[posts objectAtIndex:0] Title]);
                                                     NSLog(@"%@", nextPageIdentifier);
                                                     [_HNPostsArray addObjectsFromArray:posts];
                                                     [self.tableView reloadData];
                                                     
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:user_id, @"user_id", post_url, @"post_url", post_url_domain, @"post_url_domain", post_title, @"post_title", nil];
    [manager POST:markPostURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"success JSON: %@", responseObject);
              [self handleResponse:responseObject];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failed ERROR: %@", error);
              JFMinimalNotification *errorNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError
                                                                                                  title:@"Error!"
                                                                                               subTitle:[error localizedDescription]
                                                                                         dismissalDelay:3.0
                                                                                           touchHandler:^{
                                                                                               [errorNotification dismiss];
                                                                                           }];
              
              [errorNotification setTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
              [errorNotification setSubTitleFont:[UIFont fontWithName:fontForTableViewLight size:15]];
              [self.navigationController.view addSubview:errorNotification];
              
              [errorNotification show];
          }];
}


- (void)handleResponse:(id)response {
    if (response[@"success"]) {
        JFMinimalNotification *successNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess
                                                                                            title:@"Success!"
                                                                                         subTitle:@"You just starred this post successsfully"
                                                                                   dismissalDelay:3.0
                                                                                     touchHandler:^{
                                                                                         [successNotification dismiss];
                                                                                     }];
                                                      
        [successNotification setTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [successNotification setSubTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [self.navigationController.view addSubview:successNotification];

        [successNotification show];
    }else {
        JFMinimalNotification *errorNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError
                                                                                          title:@"Error!"
                                                                                       subTitle:response[@"error"]
                                                                                 dismissalDelay:3.0
                                                                                   touchHandler:^{
                                                                                       // FIXME: dismiss doesn't work
                                                                                       [errorNotification dismiss];
                                                                                   }];
        [errorNotification setTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [errorNotification setSubTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [self.navigationController.view addSubview:errorNotification];
        
        [errorNotification show];
    }
}

#pragma mark - get favorite posts & dates information

- (void)getFavoritePosts {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSString *user_email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    NSString *facebook_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    NSString *facebook_auth_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_auth_token"];
    NSDictionary *params;
    if ([FBSDKAccessToken currentAccessToken]) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys: facebook_id, @"facebook_id", facebook_auth_token, @"facebook_auth_token", user_email, @"user_email", username, @"username", nil];
    }else if (user_email) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:user_email, @"user_email", password, @"password", nil];
    }else {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    [manager GET:postsOfUserURL
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self handleFavoritePostsResponse:responseObject];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)handleFavoritePostsResponse:(id)response {
    if (response[@"success"]) {
        _favoritePosts = [[NSMutableDictionary alloc] initWithDictionary:response[@"info"]];
        [self.tableView reloadData];
    }else {
        //show alert
        JFMinimalNotification *errorNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleWarning
                                                                                          title:@"Something went wrong"
                                                                                       subTitle:response[@"error"]
                                                                                 dismissalDelay:3.0
                                                                                   touchHandler:^{
                                                                                       // FIXME: dismiss doesn't work
                                                                                       [errorNotification dismiss];
                                                                                   }];
        [errorNotification setTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [errorNotification setSubTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [self.navigationController.view addSubview:errorNotification];
        
        [errorNotification show];

    }
}

- (void)getDifferentDatesOfPosts {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSString *user_email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    NSString *facebook_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    NSString *facebook_auth_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_auth_token"];
    NSDictionary *params;
    if ([FBSDKAccessToken currentAccessToken]) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys: facebook_id, @"facebook_id", facebook_auth_token, @"facebook_auth_token", user_email, @"user_email", username, @"username", nil];
    }else if (user_email) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:user_email, @"user_email", password, @"password", nil];
    }else {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    [manager GET:getDifferentDatesOfPostsURL
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self handleDifferentDatesOfPostsResponse:responseObject];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)handleDifferentDatesOfPostsResponse:(id)response {
    if (response[@"success"]) {
        _differentDates = response[@"info"];
    }else {
        //log error message while still showing user's favorite posts
    }
}

- (void)unmarkPost:(NSDictionary *)post atIndexPath:(NSIndexPath *)indexPath {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSString *user_email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    NSString *facebook_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    NSString *facebook_auth_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_auth_token"];
    NSDictionary *params;
    if ([FBSDKAccessToken currentAccessToken]) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys: facebook_id, @"facebook_id", facebook_auth_token, @"facebook_auth_token", user_email, @"user_email", username, @"username", post[@"url"], @"post_url", nil];
    }else if (user_email) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:user_email, @"user_email", password, @"password", post[@"url"], @"post_url", nil];
    }else {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password",post[@"url"], @"post_url", nil];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    [manager POST:unmarkPostURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [self handleUnmarkPostAtIndexPath:indexPath Response:responseObject];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)handleUnmarkPostAtIndexPath:(NSIndexPath *)indexPath Response:(id)response {
    if (response[@"success"]) {
        JFMinimalNotification *successNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleInfo
                                                                                            title:@"Note"
                                                                                         subTitle:@"You just removed this post from your list"
                                                                                   dismissalDelay:3.0
                                                                                     touchHandler:^{
                                                                                         [successNotification dismiss];
                                                                                     }];
        
        [successNotification setTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [successNotification setSubTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [self.navigationController.view addSubview:successNotification];
        [successNotification show];
        
        NSString *date = [_differentDates objectAtIndex:indexPath.section];
        NSMutableArray *favoritePostsOnDate = [NSMutableArray arrayWithArray:[_favoritePosts objectForKey:date]] ;
        
        [favoritePostsOnDate removeObjectAtIndex:indexPath.row];
        [_favoritePosts setObject:[favoritePostsOnDate copy] forKey:date];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];

    }else {
        JFMinimalNotification *errorNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError
                                                                                          title:@"Error!"
                                                                                       subTitle:response[@"error"]
                                                                                 dismissalDelay:3.0
                                                                                   touchHandler:^{
                                                                                       // FIXME: dismiss doesn't work
                                                                                       [errorNotification dismiss];
                                                                                   }];
        [errorNotification setTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [errorNotification setSubTitleFont:[UIFont fontWithName:fontForTableViewLight size:22]];
        [self.navigationController.view addSubview:errorNotification];
        
        [errorNotification show];
    }
}


@end
