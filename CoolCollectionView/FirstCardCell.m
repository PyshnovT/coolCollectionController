//
//  FirstCardCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "FirstCardCell.h"

@interface FirstCardCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation FirstCardCell

- (void)awakeFromNib {
    // Initialization code
}

+ (BOOL)handleItem:(CardItem *)item {
    return item.type == CardItemTypeFirst;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
