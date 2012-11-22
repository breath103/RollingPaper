//
//  URLDateLoader.h
//  Ryokan
//
//  Created by ANTH on 12. 2. 10..
//  Copyright (c) 2012년 TwinMoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URLDataLoadingProcess;

@protocol URLDateLoadingProcessDelegate <NSObject>
-(void) onLoadingComplete : (URLDataLoadingProcess*) process : (NSData*) data;
-(void) onLoadingFail : (URLDataLoadingProcess*) process ;
@end

@interface URLDataLoadingProcess : NSObject
{
	NSURL* url;
	NSData* data; 
	id <URLDateLoadingProcessDelegate> delegate;
	BOOL isLoaded;
	BOOL isSynchronized;
    
	NSThread* thread;
}
@property (nonatomic,strong) NSURL* url;
@property (nonatomic,strong) NSData* data;
@property (nonatomic,strong) id <URLDateLoadingProcessDelegate> delegate;
@property (nonatomic,readonly) BOOL isLoaded;
@property (nonatomic,readonly) BOOL isSynchronized;
@property (nonatomic,strong) NSThread* thread;



-(id) 	initWithURL : (NSURL*) aUrl isSync :(BOOL) bIsSynchronized;
-(void) startLoading;

@end