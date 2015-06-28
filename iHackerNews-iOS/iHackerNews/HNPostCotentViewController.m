//
//  HNPostCotentViewController.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/14/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "HNPostCotentViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <PBFlatUI/PBFlatRoundedImageView.h>
#import <QuartzCore/QuartzCore.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import "constants.h"

@interface HNPostCotentViewController ()

@property (strong, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet PBFlatRoundedImageView *errorHackerImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation HNPostCotentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.errorView.hidden = YES;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 400, 70)];
    [title setText:[self.post Title]];
    [self.view addSubview:title];
    
    self.loadingIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:FlatOrangeDark size:50];
    self.loadingIndicator.center = CGPointMake(200, 250);
    
    self.postContent = [[UIWebView alloc] initWithFrame:CGRectMake(5, self.navigationController.navigationBar.frame.size.height+10, self.view.frame.size.width-5, self.view.frame.size.height)];
    self.postContent.delegate = self;
    self.postContent.scalesPageToFit = YES;
    self.postContent.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.postContent addSubview:self.loadingIndicator];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.postContent loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.post UrlString]]]];
    [self.view addSubview:self.postContent];
    [self.loadingIndicator startAnimating];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ( [self.postContent isLoading] ) {
        [self.postContent stopLoading];
    }
    self.postContent.delegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"web view start loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"web view finished loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.loadingIndicator stopAnimating];
    self.errorView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
    [self.loadingIndicator stopAnimating];
    self.errorView.hidden = NO;
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // report the error inside the webview
    NSString* errorString = error.localizedDescription;
    self.errorView.backgroundColor = [[UIColor alloc] initWithRed:236 green:240 blue:241 alpha:1.0];
    
    self.errorHackerImageView.image = [UIImage imageNamed:@"network_error_view_image"];
    self.errorHackerImageView.center = CGPointMake(self.errorView.frame.size.width/2, self.errorView.frame.size.height/2 - 50);
    self.errorMessageLabel.center = CGPointMake(self.errorView.frame.size.width/2, self.errorView.frame.size.height/2 - 25 + self.errorHackerImageView.frame.size.height);
    self.errorMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.errorMessageLabel.numberOfLines = 0;
    [self.errorMessageLabel setTextAlignment:NSTextAlignmentCenter];
    self.errorMessageLabel.text = errorString;
    self.errorMessageLabel.font = [UIFont fontWithName:fontForAppBold size:18];
    self.errorMessageLabel.textColor = FlatRedDark;
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
