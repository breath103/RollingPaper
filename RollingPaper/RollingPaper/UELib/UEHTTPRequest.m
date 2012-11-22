//
//  HTTPRequest.m
//  HTTPRequest
//
//  Created by Woo Ram Park on 09. 04. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UEHTTPRequest.h"


@implementation UEHTTPRequest

@synthesize receivedData;
@synthesize response;
@synthesize result;
@synthesize target;
@synthesize selector;

- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject
{
	// URL Request 객체 생성
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:5.0f];
	
	// 통신방식 정의 (POST, GET)
	[request setHTTPMethod:@"POST"];
	
	// bodyObject의 객체가 존재할 경우 QueryString형태로 변환
	if(bodyObject)
	{
		// 임시 변수 선언
		NSMutableArray *parts = [NSMutableArray array];
		NSString *part;
		id key;
		id value;
		
		// 값을 하나하나 변환
		for(key in bodyObject)
		{
			value = [bodyObject objectForKey:key];
			part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
														[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[parts addObject:part];
		}
		
		// 값들을 &로 연결하여 Body에 사용
		[request setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	// Request를 사용하여 실제 연결을 시도하는 NSURLConnection 인스턴스 생성
    
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    
	// 정상적으로 연결이 되었다면
	if(connection)
	{
		// 데이터를 전송받을 멤버 변수 초기화
		receivedData = [[NSMutableData alloc] init];
		return YES;
	}
	
	return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	// 데이터를 전송받기 전에 호출되는 메서드, 우선 Response의 헤더만을 먼저 받아 온다.
	//[receivedData setLength:0];
	self.response = aResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// 데이터를 전송받는 도중에 호출되는 메서드, 여러번에 나누어 호출될 수 있으므로 appendData를 사용한다.
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// 에러가 발생되었을 경우 호출되는 메서드
	NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// 데이터 전송이 끝났을 때 호출되는 메서드, 전송받은 데이터를 NSString형태로 변환한다.
	result = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	// 델리게이트가 설정되어있다면 실행한다.
	if(target)
	{
		[target performSelector:selector withObject:result];
	}
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
	// 데이터 수신이 완료된 이후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
	self.target   = aTarget;
	self.selector = aSelector;
}

- (void)dealloc
{
    
    self.receivedData = NULL;
	self.response     = NULL;
	self.result       = NULL;
	
}

@end
