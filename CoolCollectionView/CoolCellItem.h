//
//  CardItem.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CardItemType) {
    CardItemTypeNone,
    CardItemTypeBuy,
    CardItemTypeNote
};

@interface CoolCellItem : NSObject

@property (nonatomic) CardItemType type;

@property (nonatomic, strong) NSString *title;

@end
