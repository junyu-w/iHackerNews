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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel; //for test only
@property (weak, nonatomic) IBOutlet UIButton *userLogOutButton;

@end

@implementation ViewController

#pragma mark - view lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = CGPointMake(160, 350);
    [self.view addSubview:loginButton];
    if ([self userHasLoggedIn]) {
        [self setUpUserProfile];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self userHasLoggedIn]) {
        [self performSegueWithIdentifier:@"pop up log in view" sender:self];
    }
}

- (void)setUpUserProfile {
    self.usernameLabel.text = [@"username: " stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    self.emailLabel.text = [@"email: " stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    self.passwordLabel.text = [@"password: " stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
}

- (IBAction)backButtonOnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"user goes back to hn post table view");
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //segue to log in view controller
    [self performSegueWithIdentifier:@"pop up log in view after log out" sender:self];
}


@end
