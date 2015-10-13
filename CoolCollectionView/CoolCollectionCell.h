
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

@property (nonatomic, strong) NSString *title;

+ (BOOL)handleItem:(CoolCellItem *)item;

@end
