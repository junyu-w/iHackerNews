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
#import <AFNetworking/AFNetworking.h>
#import "Utils.h"
#import "constants.h"

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
    
    self.usernameInputField.delegate = self;
    self.passwordInputField.delegate = self;
    self.emailInputField.delegate = self;
    
    // end editing and hide keyboard when user touches screen outside of textfield
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
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

#pragma mark - slide textfield when editing

- (void) animateTextField:(UITextField*)textField up:(BOOL)up {
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
}

#pragma mark - sign up process

- (IBAction)signUpButtonOnClick:(id)sender {
    if ([self authenticateInputFields]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        NSDictionary *parameters = @{@"username":self.usernameInputField.text,
                                     @"user_email":self.emailInputField.text,
                                     @"password":self.passwordInputField.text};
        [manager POST:createUserURL
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"JSON: %@", responseObject);
                  [self handleServerResponse:responseObject];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"ERROR: %@", error);
                  SCLAlertView *userSignUpFailedAlert = [[SCLAlertView alloc] init];
                  [userSignUpFailedAlert showWarning:self
                                               title:@"Error"
                                            subTitle:[error localizedDescription]
                                    closeButtonTitle:@"OK"
                                            duration:0.0f];
              }];
    }
}


- (void)handleServerResponse:(id)response {
    if (response[@"success"]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.usernameInputField.text forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordInputField.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:self.emailInputField.text forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:response[@"user_info"][@"user_id"] forKey:@"user_id"];
        //segue to hn post table view
        [self performSegueWithIdentifier:@"pop up hn post table view after sign up" sender:self];
    }else {
        //show alerts
        SCLAlertView *userCreateFailureAlert = [[SCLAlertView alloc] init];
        [userCreateFailureAlert showWarning:self
                                      title:@"Error"
                                   subTitle:response[@"error"]
                           closeButtonTitle:@"OK"
                                   duration:0.0f];
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
            return NO;
        }else {
            if (self.usernameInputField.text.length < 3) {
                SCLAlertView *usernameTooShortAlert = [[SCLAlertView alloc] init];
                [usernameTooShortAlert showWarning:self
                                             title:@"Error"
                                          subTitle:@"Username needs to be at least 3 characters"
                                  closeButtonTitle:@"OK"
                                          duration:0.0f];
                return NO;
            }else if (self.passwordInputField.text.length < 6) {
                SCLAlertView *passwordTooShortAlert = [[SCLAlertView alloc] init];
                [passwordTooShortAlert showWarning:self
                                             title:@"Error"
                                          subTitle:@"Password needs to be at least 6 characters"
                                  closeButtonTitle:@"OK"
                                          duration:0.0f];
                return NO;
            }else {
                NSRange whiteSpaceRange = [self.usernameInputField.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                if (whiteSpaceRange.location != NSNotFound) {
                    NSLog(@"Found white space in username");
                    SCLAlertView *usernameContainsWhiteSpaceAlert = [[SCLAlertView alloc] init];
                    [usernameContainsWhiteSpaceAlert showWarning:self
                                                           title:@"Error"
                                                        subTitle:@"Username can't contain whitespace"
                                                closeButtonTitle:@"OK"
                                                        duration:0.0f];
                    return NO;
                }
                return YES;
            }
        }
    }else {
        SCLAlertView *emptyInputFieldAlert = [[SCLAlertView alloc] init];
        [emptyInputFieldAlert showWarning:self
                                    title:@"Error"
                                 subTitle:@"Input fields cannot be empty"
                         closeButtonTitle:@"OK"
                                 duration:0.0f];
        return NO;
    }
}





@end
