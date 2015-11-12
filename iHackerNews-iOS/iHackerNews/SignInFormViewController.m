//
//  SignInFormViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/6/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "SignInFormViewController.h"
#import <ChameleonFramework/Chameleon.h>
//#import <PBFlatUI/PBFlatTextField.h>
#import <PBFlatUI/PBFlatButton.h>
#import <PBFlatUI/PBFlatRoundedImageView.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <AFNetWorking/AFNetWorking.h>
#import "Utils.h"
#import "constants.h"
#import "SWRevealViewController.h"
#import "HNPostsTableViewController.h"
#import "MRProgress.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@interface SignInFormViewController ()
//@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *usernameInputField;
//@property (weak, nonatomic) IBOutlet PBFlatTextfield *passwordInputField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *usernameInputField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordInputField;
@property (weak, nonatomic) IBOutlet PBFlatButton *signInButton;

@end

@implementation SignInFormViewController

#pragma mark - view controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0]; //the cloud color
    [self setUpButtons];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

/**
 *  Set up basic UI components
 */
- (void)setUpButtons {
    self.usernameInputField.placeholder = @"Enter your username or email here";
//    [self.usernameInputField setPlaceholder:@"Enter your username or email here"
//                              floatingTitle:@"Username/Email"];
    self.passwordInputField.placeholder = @"Enter your password here";
//    [self.passwordInputField setPlaceholder:@"Enter your password here"
//                              floatingTitle:@"Password"];
    self.passwordInputField.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


- (IBAction)backButtonOnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"user dismissed sign in view controller");
    }];
}

#pragma mark - sign in process

- (IBAction)signInButtonOnClick:(id)sender {
    // dismiss keyboard
    [self.usernameInputField resignFirstResponder];
    [self.passwordInputField resignFirstResponder];
    
    if ([self authenticateInputFields]) {
        NSDictionary *userInput;
        NSString *getUserEndpoint;
        if ([self signInUsingEmail]) {
            NSLog(@"user chooses to sign in with email");
            userInput = [[NSDictionary alloc] initWithObjectsAndKeys:self.usernameInputField.text, @"user_email", self.passwordInputField.text, @"password", nil];
            getUserEndpoint = [Utils appendEncodedDictionary:userInput
                                                       ToURL:getUserURL];
        }else {
            NSLog(@"user chooses to sign in with username");
            userInput = [[NSDictionary alloc] initWithObjectsAndKeys:self.usernameInputField.text, @"username", self.passwordInputField.text, @"password", nil];
            getUserEndpoint = [Utils appendEncodedDictionary:userInput
                                                       ToURL:getUserURL];
        }
        [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:getUserEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            [self handleServerResponse:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
            SCLAlertView *userSignInFailureAlert = [[SCLAlertView alloc] init];
            [userSignInFailureAlert showWarning:self
                                          title:@"Error"
                                       subTitle:[error localizedDescription]
                               closeButtonTitle:@"OK"
                                       duration:0.0f];
        }];
    }
}


/**
 *  check to see if user choose to sign in using email or username
 *
 *  @return YES or NO
 */
- (BOOL)signInUsingEmail {
    if ([Utils NSStringIsValidEmail:self.usernameInputField.text]) {
        return YES;
    }else {
        return NO;
    }
}

/**
 *  Check if all input fields have been filled
 *
 *  @return YES or NO
 */
- (BOOL)authenticateInputFields {
    if (self.usernameInputField.text.length == 0 || self.passwordInputField.text.length == 0) {
        SCLAlertView *inputFieldsEmptyAlert = [[SCLAlertView alloc] init];
        [inputFieldsEmptyAlert showWarning:self
                                     title:@"Error"
                                  subTitle:@"Username or password cannot be empty"
                          closeButtonTitle:@"OK"
                                  duration:0.0f];
        return NO;
    }else {
        return YES;
    }
}

/**
 *  Handler subsequent action after user clicks the sign in button
 *
 *  @param response server reply
 */
- (void)handleServerResponse:(id)response {
    if (response[@"success"]) {
        if ([self signInUsingEmail]) {
            [[NSUserDefaults standardUserDefaults] setObject:self.usernameInputField.text forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setObject:response[@"user_info"][@"username"] forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:response[@"user_info"][@"user_id"] forKey:@"user_id"];
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:self.usernameInputField.text forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:response[@"user_info"][@"email"] forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setObject:response[@"user_info"][@"user_id"] forKey:@"user_id"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordInputField.text forKey:@"password"];
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        //segue to the HNPostTableViewController
        [self performSegueWithIdentifier:@"pop up hn post table view after sign in" sender:self];
        
        
    }else {
        //show alerts
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        SCLAlertView *userSignInFailureAlert = [[SCLAlertView alloc] init];
        [userSignInFailureAlert showWarning:self
                                      title:@"Error"
                                   subTitle:response[@"error"]
                           closeButtonTitle:@"OK"
                                   duration:0.0f];
    }
}

@end
