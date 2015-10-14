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

#pragma mark - UIView

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

#pragma mark - <CoolCollectionCell>

+ (BOOL)handleItem:(CoolCellItem *)item {
    return item.type == CellItemTypeFirst;
}

+ (CGFloat)heightOfCell {
    return 40;
}


@end
