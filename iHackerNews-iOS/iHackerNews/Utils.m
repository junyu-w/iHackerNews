//
//  Utils.m
//  iHackerNews
//
//  Created by Junyu Wang on 6/7/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import "Utils.h"

@implementation Utils

/**
 *  check if a NSString is in valid email format, credits to "http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios"
 *
 *  @param checkString string that needs to be checked
 *
 *  @return if matches then true, else false
 */
+ (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


@end
