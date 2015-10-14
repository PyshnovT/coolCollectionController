//
//  FirstCardCell.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCardCell.h"
#import "CoolCollectionCell.h"

@interface CoolBuyCardCell : UICollectionViewCell <CoolCollectionCell>

@property (nonatomic, strong) NSString *title;

@end
