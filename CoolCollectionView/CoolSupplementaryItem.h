//
//  CoolSupplementaryItem.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SupItemType) {
    SupItemTypeNone,
    SupItemTypeNote,
    SupItemTypeDate
};

@interface CoolSupplementaryItem : NSObject

@property (nonatomic) SupItemType type;

@end







