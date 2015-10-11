//
//  CardCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 05/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CollectionCardCell.h"
#import "CardLayoutAttributes.h"

@implementation CollectionCardCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    NSParameterAssert(layoutAttributes != nil);
    NSParameterAssert([layoutAttributes isKindOfClass:[CardLayoutAttributes class]]);
    
    CardLayoutAttributes *cardLayoutAttributes =
    (CardLayoutAttributes *)layoutAttributes;

    CGPoint cardOffset = cardLayoutAttributes.cardOffset;
    CGPoint cellCenter = cardLayoutAttributes.center;
    
    self.center = CGPointMake(cellCenter.x, cellCenter.y + cardOffset.y);
}

@end
