//
//  CoolSecondCardCell.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 12/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolNoteCardCell.h"
#import "CoolCellItem.h"
#import "CoolCardLayoutAttributes.h"

@interface CoolNoteCardCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *decorationView;

@property (nonatomic, getter=isShadowVisible) BOOL shadowVisible;

@end

@implementation CoolNoteCardCell

#pragma mark - UIView

- (void)awakeFromNib {
    [self commonInit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupDecorationView];
}

#pragma mark - Setups

- (void)commonInit {
    self.shadowVisible = YES;
}

- (void)setupDecorationView {
    
    self.decorationView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:14] CGPath];
    self.decorationView.layer.cornerRadius = 14;
    self.decorationView.layer.shadowOffset = CGSizeMake(0, 0);
    self.decorationView.layer.shadowOpacity = self.isShadowVisible ? 0.22 : 0.0;
    self.decorationView.layer.shadowColor = [UIColor blackColor].CGColor;
    
}

#pragma mark - Setters

- (void)setShadowVisible:(BOOL)shadowVisible {
    _shadowVisible = shadowVisible;
    
    self.decorationView.layer.shadowOpacity = shadowVisible ? 0.2 : 0.0;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

#pragma mark - Apply

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    CoolCardLayoutAttributes *supLayoutAttributes = (CoolCardLayoutAttributes *)layoutAttributes;
    
    self.shadowVisible = supLayoutAttributes.isShadowVisible;
}

#pragma mark - CoolCollectionCell

+ (BOOL)handleItem:(CoolCellItem *)item {
    return item.type == CellItemTypeNote;
}

+ (CGFloat)heightOfCell {
    return 60;
}


@end
