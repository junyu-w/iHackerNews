//
//  HNPostCotentViewController.h
//  iHackerNews
//
//  Created by Junyu Wang on 6/14/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNPostCotentViewController : UIViewController

@property (strong, nonatomic) NSString *HNTitle;
@property (strong, nonatomic) NSString *HNContent;
@property (strong, nonatomic) NSArray *HNComments;

@end
