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
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MNFloatingActionButton/MNFloatingActionButton.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>

@interface HNPostCotentViewController ()

@property (strong, nonatomic) IBOutlet UIView *errorView;
@property (strong, nonatomic) UIBarButtonItem *facebookShareButton;

@end

@implementation HNPostCotentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.errorView.hidden = YES;
    self.navigationController.navigationBar.tintColor = FlatSand;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 400, 70)];
    [title setText:[self.post Title]];
    [self.view addSubview:title];
    
    self.loadingIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:FlatOrangeDark size:50];
    self.loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    self.postContent = [[UIWebView alloc] initWithFrame:CGRectMake(5, self.navigationController.navigationBar.frame.size.height+10, self.view.frame.size.width-5, self.view.frame.size.height)];
    self.postContent.delegate = self;
    self.postContent.scalesPageToFit = YES;
    self.postContent.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.postContent addSubview:self.loadingIndicator];
    
//    self.facebookShareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fb-share-icon"]
//                                                                style:UIBarButtonItemStylePlain
//                                                               target:self
//                                                               action:@selector(shareOnFacebook)];
    self.facebookShareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(shareOnFacebook)];
    self.facebookShareButton.tintColor = FlatSand;
    self.navigationItem.rightBarButtonItem = self.facebookShareButton;
    self.navigationItem.rightBarButtonItem.tintColor = FlatSand;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_favoritePost) {
        [self.postContent loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_favoritePost[@"url"]]]];
    }else {
        [self.postContent loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.post UrlString]]]];
    }
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
    
    UIAlertView *webViewLoadedWithErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                          message:errorString
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
    webViewLoadedWithErrorAlert.delegate = self;
    [self.errorView addSubview:webViewLoadedWithErrorAlert];
    [webViewLoadedWithErrorAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - facebook sharing related functions

- (void)shareOnFacebook {
    if (_favoritePost) {
        [self shareUrlOnFacebook:_favoritePost[@"url"]];
    }else {
        [self shareUrlOnFacebook:[self.post UrlString]];
    }
}

- (void)shareUrlOnFacebook:(NSString *)url {
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [[NSURL alloc] initWithString:url];
        content.contentTitle = [self.post Title];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];

    }else {
        UIAlertView *notFbUserAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Please log in with facebook first"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
        [notFbUserAlert show];
    }
}

@end
