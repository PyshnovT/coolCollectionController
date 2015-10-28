//
//  ScrollViewInfo.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 28/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollViewInfo : NSObject
/*
@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint targetContentOffset;
*/

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic) CGPoint scrollOffset;

@end
