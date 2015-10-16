//
//  FirstCardCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolBuyCardCell.h"
#import "CoolCardLayoutAttributes.h"

@interface CoolBuyCardCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


@end

@implementation CoolBuyCardCell

#pragma mark - UIView

- (void)awakeFromNib {
    // Initialization cod
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

#pragma mark - CoolCollectionCell

+ (CellItemType)itemType {
    return CellItemTypeBuy;
}

+ (BOOL)handleItem:(CoolCellItem *)item {
    return item.type == CellItemTypeBuy;
}

+ (CGFloat)heightOfCell {
    return 50;
}

#pragma mark - Apply

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    CoolCardLayoutAttributes *cardLayoutAttributes = (CoolCardLayoutAttributes *)layoutAttributes;
    
    self.topConstraint.constant = cardLayoutAttributes.internalCellOffset;
    
}





@end
