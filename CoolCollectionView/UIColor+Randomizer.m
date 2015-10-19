//
//  UIColor+Randomizer.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 19/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "UIColor+Randomizer.h"

@implementation UIColor (Randomizer)

+ (UIColor *)randomColor {
    CGFloat randomRed = arc4random() % 255 / 255.0;
    CGFloat randomGreen = arc4random() % 255 / 255.0;
    CGFloat randomBlue = arc4random() % 255 / 255.0;

//    NSLog(@"%f", randomRed);
    
    return [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1];
}

@end
