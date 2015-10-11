
//
//  CardLayoutAttributes.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 05/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CardLayoutAttributes.h"

@interface CardLayoutAttributes ()



@end

@implementation CardLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    CardLayoutAttributes *copy = [super copyWithZone:zone];
    NSAssert([copy isKindOfClass:[self class]], @"copy must have the same class");
    copy.cardOffset = self.cardOffset;
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[CardLayoutAttributes class]]) {
        return NO;
    }
    
    CardLayoutAttributes *otherObject = object;
    if (!CGPointEqualToPoint(self.cardOffset, otherObject.cardOffset)) {
        return NO;
    }
    return [super isEqual:otherObject];
}


@end
