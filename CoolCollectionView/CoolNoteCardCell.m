//
//  CoolSecondCardCell.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 12/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolNoteCardCell.h"
#import "CoolCellItem.h"

@interface CoolNoteCardCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation CoolNoteCardCell

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

+ (BOOL)handleItem:(CoolCellItem *)item {
    return item.type == CellItemTypeNote;
}

+ (CGFloat)heightOfCell {
    return 40;
}


@end
