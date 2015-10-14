
//
//  CardLayoutAttributes.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 05/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolSupplementaryLayoutAttributes.h"

@interface CoolSupplementaryLayoutAttributes ()



@end

@implementation CoolSupplementaryLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    CoolSupplementaryLayoutAttributes *copy = [super copyWithZone:zone];
    NSAssert([copy isKindOfClass:[self class]], @"copy must have the same class");
    
    copy.shadowVisible = self.isShadowVisible;
    
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[CoolSupplementaryLayoutAttributes class]]) {
        return NO;
    }
    
    CoolSupplementaryLayoutAttributes *otherObject = object;
    if (otherObject.isShadowVisible != self.isShadowVisible) {
        return NO;
    }

    return [super isEqual:otherObject];
}


@end
