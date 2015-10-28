//
//  ScrollViewInfo.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 28/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "ScrollViewInfo.h"

@implementation ScrollViewInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"Offset: %@; Timestamp: %@", NSStringFromCGPoint(self.scrollOffset), self.currentDate];
}

@end
