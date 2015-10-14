//
//  CoolWowCardCell.h
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CoolNoteSup : UICollectionViewCell

@property (nonatomic, strong) NSString *title;

@property (weak, nonatomic) IBOutlet UIView *decorationView;

@end
