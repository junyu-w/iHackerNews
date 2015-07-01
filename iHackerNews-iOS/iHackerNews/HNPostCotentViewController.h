//
//  HNPostCotentViewController.h
//  iHackerNews
//
//  Created by Junyu Wang on 6/14/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libHN/libHN.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface HNPostCotentViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) HNPost *post;
@property (strong, nonatomic) NSDictionary *favoritePost;

@property (strong, nonatomic) UIWebView *postContent;
@property (strong, nonatomic) DGActivityIndicatorView *loadingIndicator;

@end
