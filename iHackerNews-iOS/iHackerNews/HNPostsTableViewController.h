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

@property (strong, nonatomic) NSMutableArray *HNPostsArray;
@property (strong, nonatomic) NSString *HNPostType;

@property (strong, nonatomic) NSMutableDictionary *favoritePosts;
@property (strong, nonatomic) NSMutableArray *differentDates;

@end
