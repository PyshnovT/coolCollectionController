//
//  CoolSecondCardCell.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 12/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolSecondCardCell.h"
#import "CoolCellItem.h"

@interface CoolSecondCardCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation CoolSecondCardCell

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
    return item.type == CellItemTypeSecond;
}

+ (CGFloat)heightOfCell {
    return 50;
}


@end
