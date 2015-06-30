//
//  FavoritePostsTableViewController.h
//  iHackerNews
//
//  Created by Junyu Wang on 6/29/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libHN/libHN.h>

@interface FavoritePostsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *favoritePosts;
@property (strong, nonatomic) NSArray *differentDates;

@property (strong, nonatomic) NSString *HNPostType;

@end
