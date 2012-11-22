//
//  UEMemoryManager.h
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 1..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 폰의 메모리 워닝을 막기 위한 클래스 . 이 클래스를 상속받은 클래스의 객체들은 모두 UEMemoryManager에 등록되며,
 메모리 워닝 이벤트가 떴을 경우 메모리 해제가 가능한 객체를 메모리 해제한다.
 이때 메모리 해제는 가장 먼저 등록된 객체부터, 즉 FIFO방식으로 진행되며, 이는 이미 사용중인 리소스에 대한 메모리 해제를 막기 위해서다. 
 */
@interface UEMemoryReleasableObject : NSObject
{

}
-(BOOL) isReleasble;    //메모리 확보 작업이 가능한지
-(void) releaseMemory;  //메모리 해제
@end

@interface UEMemoryManager : NSObject
{
    NSMutableOrderedSet* releasableObjects;
}
+ (UEMemoryManager*)sharedInstance;
-(void) addReleasableObject : (UEMemoryReleasableObject*) releasableObject;
-(void) releaseMemory;  //메모리 해제
@end
