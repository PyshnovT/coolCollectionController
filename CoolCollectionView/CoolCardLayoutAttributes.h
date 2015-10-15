//
//  CardLayoutAttributes.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 05/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolCardLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

@property (nonatomic, getter=isShadowVisible) BOOL shadowVisible;

@end
