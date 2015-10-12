//
//  CoolCollectionViewLayout.h
//  rocketbank
//
//  Created by Тимофей Пышнов on 02/10/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat interSectionSpaceY;
@property (nonatomic) CGFloat interItemSpaceY;
@property (nonatomic) CGFloat cellHeight;

@property (nonatomic) UIEdgeInsets insets;

@end
