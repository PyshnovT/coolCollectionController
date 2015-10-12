//
//  CoolCollectionViewLayout.m
//  rocketbank
//
//  Created by Тимофей Пышнов on 02/10/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolCollectionViewLayout.h"
#import "CardLayoutAttributes.h"
#import "CoolCollectionView.h"
#import "DecorationView.h"

@interface CoolCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo; 
@property (nonatomic, strong) NSMutableDictionary *cellBottomY;

@end

static NSString * const CardCell = @"CardCell";
static NSString * const SupKind = @"title";

@implementation CoolCollectionViewLayout

#pragma mark - Class

+ (Class)layoutAttributesClass {
    return [CardLayoutAttributes class];
}

#pragma mark - Setup

- (void)awakeFromNib {
    [self setupLayout];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout {
    self.cellHeight = 40;
    self.interItemSpaceY = 0;
    self.interSectionSpaceY = 20;
    self.cellBottomY = [NSMutableDictionary dictionary];
    
    [self registerClass:[DecorationView class] forDecorationViewOfKind:@"bottomLine"];
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    NSInteger lastItemIndex = MAX(0, [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:numberOfSections - 1] - 1);
    
    NSIndexPath *indexPathForLastCard = [NSIndexPath indexPathForItem:lastItemIndex inSection:numberOfSections-1];
    
  //  CGPoint offset = [self cardOffsetForIndexPath:indexPathForLastCard];
    
    
    NSNumber *tag = [self tagForIndexPath:indexPathForLastCard];
    CGFloat height = [self.cellBottomY[tag] floatValue] + 1000;
   // NSLog(@"%f", height);
    
    
    
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, height);
    
    return size;
}

- (void)prepareLayout {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplementaryInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSNumber *tag = [self tagForIndexPath:indexPath];

            
            NSDictionary *layoutInfoForIndexPath = [self layoutInfoForIndexPath:indexPath];
            self.cellBottomY[tag] = [layoutInfoForIndexPath objectForKey:@"currentBottomY"];//[NSNumber numberWithFloat:newBottomY];
            
            CardLayoutAttributes *itemAttributes = [CardLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGSize cardSize = [[layoutInfoForIndexPath objectForKey:@"cardSize"] CGSizeValue];
            CGSize supplementaryViewSize = [[layoutInfoForIndexPath objectForKey:@"supplementaryViewSize"] CGSizeValue];
            CGFloat previousBottomY = [[layoutInfoForIndexPath objectForKey:@"previousBottomY"] floatValue];
            
      //      NSLog(@"%f", previousBottomY);
            
            itemAttributes.size = cardSize;
            itemAttributes.center = CGPointMake(cardSize.width / 2.0, previousBottomY + (cardSize.height) / 2.0 + supplementaryViewSize.height);
            
            cellLayoutInfo[indexPath] = itemAttributes;
            
            if (!indexPath.item) {
                CardLayoutAttributes *supAttributes = [CardLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SupKind withIndexPath:indexPath];
                supAttributes.size = supplementaryViewSize;
                
                
                
                
                
                
                
                
                
                
                
                
                
                CGFloat y = previousBottomY;
                
                
                
                
                CGFloat yOffset = self.collectionView.contentOffset.y;
                
                CGFloat minimumTopOffset = MIN(8 * indexPath.section, 8 * 2);
                
                if (y < yOffset + minimumTopOffset) { // всё, пошла цепочечка
                    y = yOffset + minimumTopOffset;
                }
                
                supAttributes.center = CGPointMake(supplementaryViewSize.width / 2.0, y + supplementaryViewSize.height / 2.0);
                
                supplementaryInfo[indexPath] = supAttributes;
                
            }
            
        }
    }
    
    newLayoutInfo[CardCell] = cellLayoutInfo;
    newLayoutInfo[SupKind] = supplementaryInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    for (NSString *key in self.layoutInfo) {
        NSDictionary *attributesDict = [self.layoutInfo objectForKey:key];
        
        for (NSIndexPath *indexKey in attributesDict) {
            
            
            CardLayoutAttributes *attributes = [(CardLayoutAttributes *)[attributesDict objectForKey:indexKey] copy];
            CardLayoutAttributes *nextItemAttributes;
            NSIndexPath *nextPath = [NSIndexPath indexPathForItem:indexKey.item inSection:indexKey.section + 1];
            
            if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
                nextItemAttributes = (CardLayoutAttributes *)[attributesDict objectForKey:nextPath];
            }
            
            CGFloat y;
            
            if (key == SupKind) { //двигать только сапы
                CGRect supFrame = attributes.frame;
                
                if (((CoolCollectionView *)self.collectionView).cardBehaviourEnabled) {
                    NSIndexPath *decorationIndexPath = indexKey;
                    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"bottomLine"
                                                                                                                                         withIndexPath:decorationIndexPath];
                        
                    decorationAttributes.frame = CGRectMake(0.0f,
                                                            supFrame.origin.y + supFrame.size.height,
                                                            self.collectionViewContentSize.width,
                                                            2);
                    
                    decorationAttributes.zIndex = indexKey.section;
                
                    
                    CGFloat yOffset = self.collectionView.contentOffset.y;
                    CGFloat minimumTopOffset = MIN(8 * indexKey.section, 8 * 2);
                    
                    NSIndexPath *firstCardIndexInCurrentSection = [NSIndexPath indexPathForItem:0 inSection:indexKey.section];
                    CardLayoutAttributes *cardAttributes = self.layoutInfo[CardCell][firstCardIndexInCurrentSection];
                    CGFloat zN = (cardAttributes.frame.origin.y - yOffset - minimumTopOffset) / supFrame.size.height;
                    
                    CGFloat d = MIN(1, 1 - zN);
                    
                    decorationAttributes.alpha = d;
                   // NSLog(@"Z: %f", zN);
                 //   NSLog(@"%f %f", attributes.frame.origin.y, nextItemAttributes.frame.origin.y);

                    if (attributes.frame.origin.y < nextItemAttributes.frame.origin.y - supFrame.size.height + 20 || !nextItemAttributes) {
                    
                        [allAttributes addObject:decorationAttributes];
                    }
                
                
                    
                } else {
                    y = supFrame.origin.y;
                }

                if (((CoolCollectionView *)self.collectionView).cardBehaviourEnabled) {
             //   attributes.frame = CGRectMake(supFrame.origin.x, y, supFrame.size.width, supFrame.size.height); // кароч, они тупо не сихнронятся
                //NSLog(@"я:%lu,  %f", indexKey.section, attributes.frame.origin.y);
               // NSLog(@"ПИДОР СЛЕДУЮЩИЙ %lu %f", nextPath.section, nextItemAttributes.frame.origin.y);
                }

            }

            
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                
                [allAttributes addObject:attributes];
                
            }
        }
    }
    
    
    return allAttributes;
}

- (CardLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CardLayoutAttributes *attributes = self.layoutInfo[CardCell][indexPath];
    attributes.cardOffset = [self cardOffsetForIndexPath:indexPath];
    
    return attributes;
}

- (CardLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    CardLayoutAttributes *attributes = self.layoutInfo[elementKind][indexPath];
    attributes.cardOffset = [self cardOffsetForIndexPath:indexPath];
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (newBounds.size.width != self.collectionView.bounds.size.width) {
        return YES;
    }
    
    return ((CoolCollectionView *)self.collectionView).cardBehaviourEnabled;
}

#pragma mark - Taging

- (NSIndexPath *)indexPathForTag:(NSNumber *)tag {
    NSInteger intTag = [tag integerValue];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    NSInteger totalRow = 0;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            if (totalRow == intTag) {
                return [NSIndexPath indexPathForItem:item inSection:section];
            }
            
            totalRow++;
        }
    }
    
    return nil;
}

- (NSNumber *)tagForIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionSum = 0;
    
    for (int i = 0; i < indexPath.section; i++) {
        sectionSum += [self.collectionView numberOfItemsInSection:i];
    }
    
    NSInteger tag = sectionSum + indexPath.item;
    return [NSNumber numberWithInteger:tag];
}

- (NSIndexPath *)previousIndexPathForIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    
    if (item == 0) {
        
        if (section == 0) {
            item -= 1;
            section = 0;
        } else {
            item = [self.collectionView numberOfItemsInSection:indexPath.section-1] - 1;
            section -= 1;
        }
        
    } else {
        item -= 1;
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (BOOL)isTheLastItemInSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
}

#pragma mark - Card Behaviour
/*
- (CGPoint)cardOffsetForLayoutAttributes:(CardLayoutAttributes *)layoutAttributes andIndexPath:(NSIndexPath *)indexPath {
    
        //
    
    NSParameterAssert(layoutAttributes != nil);     
    NSParameterAssert([layoutAttributes isKindOfClass:[CardLayoutAttributes class]]);

    CGPoint offset = CGPointZero;
    
    if (!((CoolCollectionView *)self.collectionView).cardBehaviourEnabled) {
        return offset;
    }
    
    offset = CGPointMake(0, roundf((self.collectionView.contentOffset.y / -10)) * indexPath.section); // вообще случайный офсет
  //  NSLog(@"Offset %.0f для индекса: Секция:%ld  Item:%ld", offset.y, (long)indexPath.section, (long)indexPath.item);
//NSLog(@"%ld", (long)indexPath.item);
    
    return offset;
}
*/

- (CGPoint)cardOffsetForIndexPath:(NSIndexPath *)indexPath {
    CGPoint offset = CGPointZero;
    
    if (!((CoolCollectionView *)self.collectionView).cardBehaviourEnabled) {
        return offset;
    }
    
   // offset = CGPointMake(0, roundf((self.collectionView.contentOffset.y / -10)) * indexPath.section); // вообще случайный офсет
    //  NSLog(@"Offset %.0f для индекса: Секция:%ld  Item:%ld", offset.y, (long)indexPath.section, (long)indexPath.item);
    //NSLog(@"%ld", (long)indexPath.item);
    
    offset = CGPointMake(0, roundf((self.collectionView.contentOffset.y / -10)) * indexPath.section);//CGPointMake(0, 200);
    
    return offset;
    
}

#pragma mark - Size

- (CGSize)sizeForCardAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.cellHeight;
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
}

- (CGSize)sizeForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item) return CGSizeZero;
    
    CGFloat height = 60;
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
    
}

- (NSInteger)randomHeight {
    return arc4random() % 300 + 200;
}

- (NSDictionary *)layoutInfoForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
  //  NSLog(@"PATH: %@", previousIndexPath);
    NSNumber *tag = [self tagForIndexPath:previousIndexPath];
    
    CGFloat previousBottomY = [self.cellBottomY[tag] floatValue];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    CGFloat sectionOffset = [self isTheLastItemInSectionForIndexPath:indexPath] && indexPath.section != sectionCount-1 ? self.interSectionSpaceY : 0;
    
    CGFloat itemOffset = [self isTheLastItemInSectionForIndexPath:indexPath] ? 0 : self.interItemSpaceY;
    
    CGSize cardSize = [self sizeForCardAtIndexPath:indexPath];
    CGSize supplementaryViewSize = [self sizeForSupplementaryViewAtIndexPath:indexPath];
    
    CGFloat currentBottomY = previousBottomY + itemOffset + cardSize.height + sectionOffset + supplementaryViewSize.height;
    
    NSDictionary *info = @{@"previousBottomY": [NSNumber numberWithFloat:previousBottomY],
                           @"sectionOffset": [NSNumber numberWithFloat:sectionOffset],
                           @"itemOffset": [NSNumber numberWithFloat:itemOffset],
                           @"cardSize": [NSValue valueWithCGSize:cardSize],
                           @"supplementaryViewSize": [NSValue valueWithCGSize:supplementaryViewSize],
                           @"currentBottomY": [NSNumber numberWithFloat:currentBottomY]};

    return info;
}



@end
