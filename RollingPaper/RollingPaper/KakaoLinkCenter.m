//
// Copyright 2011 Kakao Corp. All rights reserved.
// @author kakaolink@kakao.com
// @version 2.0
//
#import "KakaoLinkCenter.h"
#import "JSONKit.h"


static NSString *StringByAddingPercentEscapesForURLArgument(NSString *string) {
	NSString *escapedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																				  (CFStringRef)string,
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
	return [escapedString autorelease];
}

static NSString *HTTPArgumentsStringForParameters(NSDictionary *parameters) {
	NSMutableArray *arguments = [NSMutableArray array];
    
	for (NSString *key in parameters) {
		NSString *parameter = [NSString stringWithFormat:@"%@=%@", key, StringByAddingPercentEscapesForURLArgument([parameters objectForKey:key])];
		[arguments addObject:parameter];
	}
	
	return [arguments componentsJoinedByString:@"&"];
}

static NSString *const KakaoLinkApiVerstion = @"2.0";
static NSString *const KakaoLinkURLBaseString = @"kakaolink://sendurl";

static NSString *const StoryLinkApiVersion = @"1.0";
static NSString *const StoryLinkURLBaseString = @"storylink://posting";

@implementation KakaoLinkCenter

#pragma mark -

+ (NSString *)URLStringForParameters:(NSDictionary *)parameters baseString:(NSString *)baseString {
	NSString *argumentsString = HTTPArgumentsStringForParameters(parameters);
	NSString *URLString = [NSString stringWithFormat:@"%@?%@", baseString, argumentsString];
	return URLString;
}

// for KakaoLink

+ (NSString *)kakaoLinkURLStringForParameters:(NSDictionary *)parameters {
	return [self URLStringForParameters:parameters baseString:KakaoLinkURLBaseString];
}

+ (BOOL)openKakaoLinkWithParams:(NSDictionary *)params {
    NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:params];
    [_params setObject:KakaoLinkApiVerstion forKey:@"apiver"];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self kakaoLinkURLStringForParameters:_params]]];
}

// for StoryLink

+ (NSString *)storyLinkURLStringForParameters:(NSDictionary *)parameters {
	return [self URLStringForParameters:parameters baseString:StoryLinkURLBaseString];
}

+ (BOOL)openStoryLinkWithParams:(NSDictionary *)params {
    NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:params];
    [_params setObject:StoryLinkApiVersion forKey:@"apiver"];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self storyLinkURLStringForParameters:_params]]];
}

#pragma mark -

+ (BOOL)canOpenKakaoLink {
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:KakaoLinkURLBaseString]];
}

+ (BOOL)openKakaoLinkWithURL:(NSString *)referenceURLString
				  appVersion:(NSString *)appVersion
				 appBundleID:(NSString *)appBundleID 
                     appName:(NSString *)appName 
					 message:(NSString *)message {
	if (!referenceURLString || !message || !appVersion || !appBundleID ||!appName) 
		return NO;
	
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                referenceURLString, @"url",
                                message, @"msg",
                                appVersion, @"appver",
                                appBundleID, @"appid",
                                appName, @"appname",
                                @"link", @"type",
                                nil];
    
	return [self openKakaoLinkWithParams:parameters];
}


+ (BOOL)openKakaoAppLinkWithMessage:(NSString *)message
								URL:(NSString *)referenceURLString
						appBundleID:(NSString *)appBundleID
						 appVersion:(NSString *)appVersion
							appName:(NSString *)appName
					  metaInfoArray:(NSArray *)metaInfoArray {
	
	BOOL avalibleAppLink = !message || !appVersion || !appBundleID || !appName || !metaInfoArray || [metaInfoArray count] > 0;
	if (!avalibleAppLink)
		return NO;
    
    NSString *appDataString = [[NSDictionary dictionaryWithObject:metaInfoArray forKey:@"metainfo"] JSONString];
    if ( appDataString == nil )
        return NO;
    
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       referenceURLString, @"url",
                                       message, @"msg",
                                       appVersion, @"appver",
                                       appBundleID, @"appid",
                                       appName, @"appname",
                                       @"app", @"type",
                                       appDataString, @"metainfo",
                                       nil];
    
	return [self openKakaoLinkWithParams:parameters];
}


+ (BOOL)canOpenStoryLink {
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:StoryLinkURLBaseString]];
}

+ (BOOL)openStoryLinkWithPost:(NSString *)post
				  appBundleID:(NSString *)appBundleID
				   appVersion:(NSString *)appVersion
					  appName:(NSString *)appName
					  urlInfo:(NSDictionary *)urlInfoDict {
	
	if (!post|| !appBundleID || !appVersion || !appName)
		return NO;
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   post, @"post",
									   appBundleID, @"appid",
									   appVersion, @"appver",
									   appName, @"appname",
									   nil];
	
	if (urlInfoDict.count > 0) {
		[parameters setObject:[urlInfoDict JSONString] forKey:@"urlinfo"];
	}
	
	return [self openStoryLinkWithParams:parameters];
}

@end
