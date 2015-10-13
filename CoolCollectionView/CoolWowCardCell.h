//
//  CoolWowCardCell.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoolCollectionCell.h"

@interface CoolWowCardCell : UICollectionViewCell <CoolCollectionCell>

@property (nonatomic, strong) NSString *title;

@end
