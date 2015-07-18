//
//  ViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/3/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ChameleonFramework/Chameleon.h>
#import "constants.h"
#import <PBFlatUI/PBFlatRoundedImageView.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *userLogOutButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet PBFlatRoundedImageView *userProfilePictureImageView;

@end

@implementation ViewController

#pragma mark - view lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = FlatWhite;
    if ([self userHasLoggedIn]) {
        [self setUpUserProfile];
        [self setUpLogoutButton];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self userHasLoggedIn]) {
        [self performSegueWithIdentifier:@"pop up log in view" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI set up

- (void)setUpUserProfile {

    self.usernameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.usernameLabel.numberOfLines = 0;
    self.emailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.usernameLabel.numberOfLines = 0;
    
    self.usernameLabel.text = [@"" stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    self.emailLabel.text = [@"" stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.emailLabel.textAlignment = NSTextAlignmentCenter;
    
    UIFont *userProfileLabelsFont = [UIFont fontWithName:fontForAppLight size:17];
    self.usernameLabel.font = userProfileLabelsFont;
    self.emailLabel.font = userProfileLabelsFont;
    self.usernameLabel.textColor = FlatOrange;
    self.emailLabel.textColor = FlatOrange;

    self.userProfilePictureImageView.image = [UIImage imageNamed:@"default_user_profile_picture"];
    
}

- (void)setUpLogoutButton {
    self.userLogOutButton.titleLabel.font = [UIFont fontWithName:fontForAppBold size:16];
    self.userLogOutButton.titleLabel.textColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0];
    self.userLogOutButton.layer.cornerRadius = 1;
    if ([FBSDKAccessToken currentAccessToken]) {
        self.userLogOutButton.backgroundColor = FlatSkyBlue;
        self.userLogOutButton.titleLabel.text = @"Facebook Sign Out";
    }else {
        self.userLogOutButton.backgroundColor = FlatWatermelon;
        self.userLogOutButton.titleLabel.text = @"Sign Out";
    }
}

- (IBAction)backButtonOnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"user goes back to hn post table view");
    }];
}

#pragma mark - check user login

- (BOOL)userHasLoggedIn {
    return [FBSDKAccessToken currentAccessToken] != nil || ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"password"] != nil);
}

#pragma mark - user log out

- (IBAction)userLogOutButtonOnClick:(id)sender {
    //clear stored user info
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"facebook_id"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"facebook_auth_token"];
    if ([FBSDKAccessToken currentAccessToken]) {
        //facebook user log out
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        NSLog(@"facebook user log out");
        [loginManager logOut];
        [self performSegueWithIdentifier:@"pop up log in view after log out" sender:self];
    }else {
        //segue to log in view controller
        [self performSegueWithIdentifier:@"pop up log in view after log out" sender:self];
    }
}

#pragma mark - facebook user



@end
