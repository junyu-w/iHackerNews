//
//  constants.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/7/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "constants.h"

@implementation constants

NSString* const serverURL = @"http://localhost:3000/";

NSString* const getUserURL = @"http://localhost:3000/users/id?";
NSString* const createUserURL = @"http://localhost:3000/users";

NSString* const markPostURL = @"http://localhost:3000/mark_post";
NSString* const unmarkPostURL = @"http://localhost:3000/unmark_post";

NSString* const postsOfUserURL = @"http://localhost:3000/posts_of_user";
NSString* const getDifferentDatesOfPostsURL = @"http://localhost:3000/different_dates_of_posts";


NSString* const fontForTableViewLight = @"HelveticaNeue-Light";
NSString* const fontForTableViewBold = @"HelveticaNeue-Bold";

NSString* const fontForAppLight = @"HelveticaNeue-Light";
NSString* const fontForAppBold = @"HelveticaNeue-Bold";

@end
