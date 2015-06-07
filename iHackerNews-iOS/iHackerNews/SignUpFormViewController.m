//
//  SignUpFormViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/6/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "SignUpFormViewController.h"
#import <DKCircleButton/DKCircleButton.h>
#import <ChameleonFramework/Chameleon.h>
#import <PBFlatUI/PBFlatTextField.h>
#import <PBFlatUI/PBFlatButton.h>
#import <PBFlatUI/PBFlatRoundedImageView.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "Utils.h"

@interface SignUpFormViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backToLoginViewButton;
@property (weak, nonatomic) IBOutlet PBFlatTextfield *usernameInputField;
@property (weak, nonatomic) IBOutlet PBFlatTextfield *emailInputField;
@property (weak, nonatomic) IBOutlet PBFlatTextfield *passwordInputField;
@property (weak, nonatomic) IBOutlet PBFlatRoundedImageView *userProfilePicture;
@property (weak, nonatomic) IBOutlet PBFlatButton *signUpButton;

@end

@implementation SignUpFormViewController

#pragma mark - view controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0]; //the cloud color
    [self setUpBasicUIComponents];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  set up UIs of username/email/password textfields and default profile picture
 */
- (void)setUpBasicUIComponents {
    self.usernameInputField.placeholder = @"Enter your username";
    self.emailInputField.placeholder = @"Enter your email";
    self.passwordInputField.placeholder = @"Enter your password";
    self.passwordInputField.secureTextEntry = YES;
    self.userProfilePicture.image = [UIImage imageNamed:@"default_user_profile_picture"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/**
 *  When back button is clicked, dismiss current view controller
 *
 *  @param sender the back button
 */
- (IBAction)backButtonOnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"user dismissed sign up view controller");
    }];
}

#pragma mark - sign up process

- (IBAction)signUpButtonOnClick:(id)sender {
    if ([self authenticateInputFields]) {
        //TODO sign user up
       
    }else {
        //show alert
        
        
    }
}

- (BOOL)authenticateInputFields {
    if (self.usernameInputField.text.length > 0 && self.emailInputField.text.length > 0 && self.passwordInputField.text.length > 0) {
        if (![Utils NSStringIsValidEmail:self.emailInputField.text]) {
            SCLAlertView *invalidEmailFormatAlert = [[SCLAlertView alloc] init];
            [invalidEmailFormatAlert showWarning:self
                                           title:@"Error"
                                        subTitle:@"Invalid email format"
                                closeButtonTitle:@"OK"
                                        duration:0.0f];
            return false;
        }else {
            if (self.usernameInputField.text.length < 3) {
                SCLAlertView *usernameTooShortAlert = [[SCLAlertView alloc] init];
                [usernameTooShortAlert showWarning:self
                                             title:@"Error"
                                          subTitle:@"Username needs to be at least 3 characters"
                                  closeButtonTitle:@"OK"
                                          duration:0.0f];
                return false;
            }else if (self.passwordInputField.text.length < 6) {
                SCLAlertView *passwordTooShortAlert = [[SCLAlertView alloc] init];
                [passwordTooShortAlert showWarning:self
                                             title:@"Error"
                                          subTitle:@"Password needs to be at least 6 characters"
                                  closeButtonTitle:@"OK"
                                          duration:0.0f];
                return false;
            }else {
                return true;
            }
        }
    }else {
        SCLAlertView *emptyInputFieldAlert = [[SCLAlertView alloc] init];
        [emptyInputFieldAlert showWarning:self
                                    title:@"Error"
                                 subTitle:@"Input fields cannot be empty"
                         closeButtonTitle:@"OK"
                                 duration:0.0f];
        return false;
    }
}





@end
