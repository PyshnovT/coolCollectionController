//
//  CardLayoutAttributes.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 05/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolSupplementaryLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

@property (nonatomic, getter=isShadowVisible) BOOL shadowVisible;
@property (nonatomic, getter=isBackViewHidden) BOOL backViewHidden;

@end
