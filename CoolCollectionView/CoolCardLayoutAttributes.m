
//
//  CardLayoutAttributes.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 05/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolCardLayoutAttributes.h"

@interface CoolCardLayoutAttributes ()



@end

@implementation CoolCardLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    CoolCardLayoutAttributes *copy = [super copyWithZone:zone];
    NSAssert([copy isKindOfClass:[self class]], @"copy must have the same class");
    
    copy.shadowVisible = self.isShadowVisible;
    copy.internalYOffset = self.internalYOffset;
    copy.isHeader = self.isHeader;
    
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[CoolCardLayoutAttributes class]]) {
        return NO;
    }
    
    CoolCardLayoutAttributes *otherObject = object;
    
    if (otherObject.isShadowVisible != self.isShadowVisible) {
        return NO;
    }
    if (otherObject.internalYOffset != self.internalYOffset) {
        return NO;
    }
    if (otherObject.isHeader != self.isHeader) {
        return NO;
    }

    return [super isEqual:otherObject];
}


@end
