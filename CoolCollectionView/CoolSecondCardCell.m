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


- (void)awakeFromNib {
    // Initialization code
}

+ (BOOL)handleItem:(CoolCellItem *)item {
    return item.type == CellItemTypeSecond;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
