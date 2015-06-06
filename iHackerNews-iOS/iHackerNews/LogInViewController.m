//
//  LogInViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/5/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "LogInViewController.h"
#import <DKCircleButton/DKCircleButton.h>
#import <ChameleonFramework/Chameleon.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UIButton *SignUpButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation LogInViewController


#pragma mark - view controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:FlatOrange];
    [self setUpButton];
    [self setBackgroundImageAndLabel];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpButton {
    DKCircleButton *facebook_login_button = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    facebook_login_button.center = CGPointMake(120, 500);
    facebook_login_button.titleLabel.font = [UIFont systemFontOfSize:13];
    [facebook_login_button setBackgroundImage:[UIImage imageNamed:@"facebook_login_button"] forState:UIControlStateNormal];
    [self.view addSubview:facebook_login_button];
    [facebook_login_button addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    DKCircleButton *normal_login_button = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    normal_login_button.center = CGPointMake(250, 500);
    normal_login_button.titleLabel.font = [UIFont systemFontOfSize:13];
    [normal_login_button setBackgroundImage:[UIImage imageNamed:@"normal_login_button"] forState:UIControlStateNormal];
    [self.view addSubview:normal_login_button];
    [normal_login_button addTarget:self action:@selector(normalUserLogIn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loginWithFacebook {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"error logging into facebook");
        } else if (result.isCancelled) {
            NSLog(@"user cancelled login with facebook");
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"]) {
                // TODO: Do work
            }
        }
    }];
}

- (void)normalUserLogIn {
    //TODO: login
    [self performSegueWithIdentifier:@"show to sign up view" sender:self];
}

- (void)setBackgroundImageAndLabel {
    self.backgroundImageView.layer.masksToBounds = YES;
    self.backgroundImageView.layer.cornerRadius = 20;
    [self.SignUpButton setTitleColor:ComplementaryFlatColorOf(self.view.backgroundColor) forState:UIControlStateNormal];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
