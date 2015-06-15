//
//  HNPostCotentViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/14/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "HNPostCotentViewController.h"

@interface HNPostCotentViewController ()

@end

@implementation HNPostCotentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(120, 500, 70, 70)];
    [content setText:_HNContent];
    [self.view addSubview:content];
    
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

@end
