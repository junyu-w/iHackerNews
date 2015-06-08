//
//  Utils.h
//  iHackerNews
//
//  Created by Junyu Wang on 6/7/15.
//  Copyright (c) 2015 junyuwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (BOOL)NSStringIsValidEmail:(NSString*)checkString;

+ (NSString*) appendEncodedDictionary:(NSDictionary*)dictionary ToURL:(NSString*)url;

+ (NSString *) turnDictionaryIntoParamsOfURL:(NSDictionary*)dictionary;

+ (NSData*)encodeDictionary:(NSDictionary*)dictionary;

+ (NSString *)sendRequestToURL:(NSString *)url withData:(NSDictionary *)data withMethod: (NSString *)method;

+ (NSDictionary*)serverJsonReplyParser:(NSString*)serverReply;

@end
