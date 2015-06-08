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


#pragma mark - formatize URL

/**
 Append information in dictonary to URL, used for user verification
 
 @param dictionary  A NSDictionary that contains needed info to append to URL
 @param url The original URL
 @code
 signInInputData --> [@"username":@"user_name", @"password":@"user_password"]
 [self appendEncodedDictionary:signInInputData ToURL:@"http://example.com/user/verify?"] --> @"http://example.com/user/verify?username=user_name&password=user_password"
 @endcode
 */
+ (NSString*) appendEncodedDictionary:(NSDictionary*)dictionary ToURL:(NSString*)url
{
    return [url stringByAppendingString:[NSString stringWithFormat:@"%@", [self turnDictionaryIntoParamsOfURL:dictionary]]];
}

/**
 Turn information in dictionary to parameters of URL
 
 @param dictionary  The NSDictionary containing query information
 @code
 dictionary --> [@"username":@"user_name", @"password":@"user_password"]
 NSString* output = [self turnDictionaryIntoParamsOfURL:dictionary]
 output --> @"username=user_name&password=user_password"
 @endcode
 */
+ (NSString *) turnDictionaryIntoParamsOfURL:(NSDictionary*)dictionary
{
    
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary)
    {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return encodedDictionary;
}




//--------------------------currently not used, using AFNetWorking to communicate with server-----------------------//


/**
 encode dictionary into NSData
 
 @param dictionary  NSDictionary
 */
+ (NSData*)encodeDictionary:(NSDictionary*)dictionary
{
    NSString *encodedDictionary = [self turnDictionaryIntoParamsOfURL:dictionary];
    //NSLog(encodedDictionary);
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 send HTTP request
 
 @param url endpoint of server
 @param data    data in the body of HTTP request
 @param method  "GET", "POST", "PATCH", "DELETE"
 */
+ (NSString *)sendRequestToURL:(NSString *)url withData:(NSDictionary *)data withMethod: (NSString *)method
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [urlRequest setHTTPMethod:method];
    if([method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"])
    {
        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    NSData *httpData = [self encodeDictionary:data];
    [urlRequest setHTTPBody:httpData];
    NSHTTPURLResponse *response;
    NSError *error;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest  returningResponse:&response error:&error];
    if([response statusCode] >= 400 || [response statusCode] == 0)
    {
        NSLog(@"Status code: %ld, Error: %@",(long)[response statusCode], [error description]);
        return nil;
    }

    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

/**
 parse server reply from JSON format to NSDictionary
 
 @param serverReply the reply in JSON format sent back from server
 @return key-value pair of JSON data in NSDictionary
 */
+ (NSDictionary*)serverJsonReplyParser:(NSString*)serverReply
{
    return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[serverReply dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}


@end
