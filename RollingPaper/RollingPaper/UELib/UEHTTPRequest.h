//
//  HTTPRequest.h
//  HTTPRequest
//
//  Created by Woo Ram Park on 09. 04. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UEHTTPRequest : NSObject<NSURLConnectionDelegate>
{
	NSMutableData *receivedData;
	NSURLResponse *response;
	NSString *result;
	__weak id target;
	SEL selector;
}

- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end
