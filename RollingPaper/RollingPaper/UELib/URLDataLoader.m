///////////////////////////////////////////////////////////////////////////////////////////
//
//  URLDateLoader.m
//  Ryokan
//
//  Created by ANTH on 12. 2. 10..
//  Copyright (c) 2012년 TwinMoon. All rights reserved.
//

#import "URLDataLoader.h"


@implementation URLDataLoadingProcess

@synthesize url;
@synthesize data;
@synthesize delegate;
@synthesize isLoaded;
@synthesize thread;
@synthesize isSynchronized;
-(id) 	initWithURL : (NSURL*) aUrl isSync :(BOOL) bIsSynchronized;
{
	self = [self init];
	if(self){
		self.url = aUrl;
		isSynchronized = bIsSynchronized;
	}
	return self;
}
-(void) _load 
{	
	if(isSynchronized)
	{
		data = [NSData dataWithContentsOfURL:url];
		isLoaded = TRUE;
		if(data)
			[delegate onLoadingComplete:self :data];
		else
			[delegate onLoadingFail:self];
	}
	else
	{
		@autoreleasepool {
			data = [NSData dataWithContentsOfURL:url];
			isLoaded = TRUE;
			if(data)
				[delegate onLoadingComplete:self :data];
			else
				[delegate onLoadingFail:self];
		}	
	}
}
-(void) startLoading 
{
	if( !isSynchronized ) //aSync
	{
		thread = [[NSThread alloc]initWithTarget:self selector:@selector(_load) object:self];
		[thread start];
	}
	else //Sync 
	{
		[self _load];
	}
}
-(void) dealloc
{
	self.url 	  = NULL;
	self.data 	  = NULL;
	self.delegate = NULL;
	self.thread   = NULL;
}
@end