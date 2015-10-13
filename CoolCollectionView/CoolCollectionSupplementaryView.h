//
//  CoolCollectionSupplementaryView.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CoolCollectionSupplementaryView <NSObject>

+ (BOOL)handleItem:(CoolCardItem *)item;

@end
