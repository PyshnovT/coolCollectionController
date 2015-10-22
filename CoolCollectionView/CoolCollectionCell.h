
//
//  CollectionCard.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoolCellItem.h"

@protocol CoolCollectionCell <NSObject>

+ (BOOL)handleItem:(CoolCellItem *)item;
+ (CellItemType)itemType;
+ (CGFloat)heightOfCell;

@optional

@property (nonatomic, strong) NSString *title;

@end
