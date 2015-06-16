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

@interface HNPostsTableViewController ()

@end

#pragma mark - view controller life cycle

@implementation HNPostsTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //loginButton.center = CGPointMake(160, 350);
    //[self.view addSubview:loginButton];
    
    //TODO: do something when get new hn posts.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someSelector) name:kHNShouldReloadDataFromConfiguration object:nil];
    
    [[HNManager sharedManager] startSession];
    [self fetchHNPosts];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    //TODO: implement refresh
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
    
    cell.textLabel.text = @"Title";
    cell.detailTextLabel.text = @"Detail text";
    cell.delegate = self; //optional
    
    
    //configure left buttons
    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"star_post.png"] backgroundColor:[UIColor whiteColor]]];
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
                          [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    cell.textLabel.text = [[_HNPostsArray objectAtIndex:indexPath.row] Title];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"push to hn content view" sender:indexPath];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"push to hn content view"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        HNPostCotentViewController *HNContentVC = [segue destinationViewController];
        
        HNContentVC.HNTitle = @"test";
        HNContentVC.HNContent = @"test_content";
        HNContentVC.HNComments = @[@"test_1", @"test_2"];
    }
}


#pragma mark - check user login

- (BOOL)userHasLoggedIn {
    return [FBSDKAccessToken currentAccessToken] != nil || ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"password"] != nil);
}

#pragma mark - fetch info from HN and format them

- (void)fetchHNPosts {
    [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeTop
                                        completion:^(NSArray *posts, NSString *nextPageIdentifier) {
                                            if (posts) {
                                                NSLog(@"HN Posts: %@", [[posts objectAtIndex:0] Title]);
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
                                                     NSLog(@"HN More Posts: %@", posts);
                                                     _HNPostsArray = posts;
                                                 }else {
                                                     NSLog(@"Error fetching more posts");
                                                 }
                                             }];
}



@end
