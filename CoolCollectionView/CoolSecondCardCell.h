//
//  CoolSecondCardCell.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 12/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoolCollectionCell.h"

@interface CoolSecondCardCell : UICollectionViewCell <CoolCollectionCell>

@property (nonatomic, strong) NSString *title;

@end
