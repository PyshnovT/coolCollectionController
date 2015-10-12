//
//  FirstCardCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolFirstCardCell.h"

@interface CoolFirstCardCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CoolFirstCardCell

- (void)awakeFromNib {
    // Initialization code
}

+ (BOOL)handleItem:(CoolCardItem *)item {
    return item.type == CardItemTypeFirst;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
