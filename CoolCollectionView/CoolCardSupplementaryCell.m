//
//  SupCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolCardSupplementaryCell.h"
#import "CoolCardLayoutAttributes.h"

@interface CoolCardSupplementaryCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, getter=isShadowVisible) BOOL shadowVisible;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

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
    
    self.decorationView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:14] CGPath];
    self.decorationView.layer.cornerRadius = 14;
    self.decorationView.layer.shadowOffset = CGSizeMake(0, 0);
    self.decorationView.layer.shadowOpacity = self.isShadowVisible ? 0.22 : 0.0;
    self.decorationView.layer.shadowColor = [UIColor blackColor].CGColor;
    
}

#pragma mark - Setters

- (void)setShadowVisible:(BOOL)shadowVisible {
    _shadowVisible = shadowVisible;
    
    self.decorationView.layer.shadowOpacity = shadowVisible ? 0.22 : 0.0;
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
    self.topConstraint.constant = supLayoutAttributes.internalYOffset;
}
 

@end
