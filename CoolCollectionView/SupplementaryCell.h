//
//  SupCell.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCardCell.h"

@interface SupplementaryCell : CollectionCardCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *decorationView;

@property (weak, nonatomic) IBOutlet UIView *backView;

@end
