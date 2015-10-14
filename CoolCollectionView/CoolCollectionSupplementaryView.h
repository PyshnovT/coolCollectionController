//
//  CoolCollectionSupplementaryView.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoolSupplementaryItem.h"

@protocol CoolCollectionSupplementaryView <NSObject>

+ (BOOL)handleItem:(CoolSupplementaryItem *)item;
+ (CGFloat)heightOfCell;

@end
