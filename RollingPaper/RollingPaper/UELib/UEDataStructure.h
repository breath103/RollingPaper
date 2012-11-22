//
//  UEDataStructure.h
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 18..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  NSMutableArray (ExtendedMethod)
-(void) push : (id) object;
-(id)   pop  : (BOOL) bRemoveObject;
-(id) getFromBack : (BOOL) bRemoveObject;
@end