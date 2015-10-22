//
//  CardItem.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CellItemType) {
    CellItemTypeNone,
    CellItemTypeBuy,
    CellItemTypeNote,
    CellItemTypeThird
};

@interface CoolCellItem : NSObject

@property (nonatomic) CellItemType type;

@property (nonatomic, strong) NSString *title;

@end
