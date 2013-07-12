#import "NSArray+Vingle.h"
#import <Underscore.m/Underscore.h>


@implementation NSArray (Vingle)

- (NSArray *)uniqObjectsArrayByAppendingArray:(NSArray*)array
{
    if ([array count] > 0) {
        array = [self arrayByAddingObjectsFromArray:array];
        return [[NSOrderedSet orderedSetWithArray:array] array];
    }
    else {
        return self;
    }
}

- (NSArray *)uniqObjectsArrayByPreppendingArray:(NSArray*)array
{
    if ([array count] > 0) {
        array = [array arrayByAddingObjectsFromArray:self];
        array = [[array reverseObjectEnumerator] allObjects];
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:array];
        return [[set reversedOrderedSet] array];
    } else {
        return self;
    }
}

@end

