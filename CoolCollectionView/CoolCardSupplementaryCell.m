//
//  SupCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolCardSupplementaryCell.h"
#import "CoolSupplementaryLayoutAttributes.h"

@interface CoolCardSupplementaryCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CoolCardSupplementaryCell

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
    self.decorationView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    ;
    self.decorationView.layer.cornerRadius = 10;
    self.decorationView.layer.shadowOffset = CGSizeMake(0, -2);
    self.decorationView.layer.shadowOpacity = self.isShadowVisible ? 0.2 : 0.0;
    self.decorationView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    
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
    
    CoolSupplementaryLayoutAttributes *supLayoutAttributes = (CoolSupplementaryLayoutAttributes *)layoutAttributes;
    
    self.shadowVisible = supLayoutAttributes.isShadowVisible;
}

@end
