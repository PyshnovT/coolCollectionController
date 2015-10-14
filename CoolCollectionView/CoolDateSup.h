//
//  SupCell.h
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolDateSup : UICollectionViewCell

@property (nonatomic, strong) NSString *title;

@property (weak, nonatomic) IBOutlet UIView *decorationView;

@end
