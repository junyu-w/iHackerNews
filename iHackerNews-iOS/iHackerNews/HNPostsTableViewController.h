//
//  HNPostsTableViewController.h
//  iHackerNews
//
//  Created by Junyu Wang on 6/10/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BubbleTransition-objc/YPBubbleTransition.h>

@interface HNPostsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *HNPostsArray;
@property (strong, nonatomic) NSString *HNPostType;

@property (strong, nonatomic) NSDictionary *favoritePosts;
@property (strong, nonatomic) NSArray *differentDates;

@end
