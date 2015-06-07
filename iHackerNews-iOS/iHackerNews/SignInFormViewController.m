//
//  SignInFormViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/6/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "SignInFormViewController.h"

@interface SignInFormViewController ()

@end

@implementation SignInFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0]; //the cloud color
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backButtonOnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"user dismissed sign in view controller");
    }];
}

@end
