//
//  CoolCollectionViewLayout.m
//  rocketbank
//
//  Created by Тимофей Пышнов on 02/10/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolCardCollectionViewLayout.h"
#import "CoolCardCollectionView.h"
#import "CoolCardDecorationView.h"

#import "CoolCardTopDecorationView.h"
#import "CoolCardLayoutAttributes.h"

typedef NS_ENUM(NSInteger, ViewType) {
    ViewTypeNone,
    ViewTypeCell,
    ViewTypeSupplementaryView,
    ViewTypeLineDecorationView
};

@interface CoolCardCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSMutableDictionary *cellBottomY;

@property (nonatomic) NSInteger numberOfClingingCards;
@property (nonatomic) CGFloat clingYOffset;

@property (nonatomic) BOOL cardBehaviourEnabled;
@property (nonatomic) BOOL cardMagicEnabled;

@property (nonatomic) CGFloat magicOffset;

@property (nonatomic) NSInteger lastClingedCardIndex;
@property (nonatomic) CGFloat interClingCellsSpaceY;

@end

@implementation CoolCardCollectionViewLayout

#pragma mark - Base

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

#pragma mark - Setups

- (void)setupLayout {
    
    [self setupDefaultValues];
    [self registerDecorationViews];
    
}

- (void)setupDefaultValues {
    
   // [self setupKinetics];
    
    // External
    self.interItemSpaceY = 0;
    self.interSectionSpaceY = 0;
    // External
    
    self.clingYOffset = 6;
    self.magicOffset = 40;
    self.lastClingedCardIndex = 0;
    self.interClingCellsSpaceY = -40;
    
    self.cellBottomY = [NSMutableDictionary dictionary];
    
}

- (void)registerDecorationViews {
    [self registerNib:[UINib nibWithNibName:@"CoolCardDecorationView" bundle:nil] forDecorationViewOfKind:@"bottomLine"];
    [self registerClass:[CoolCardTopDecorationView class] forDecorationViewOfKind:@"hideLine"];
}

#pragma mark - Getters

- (BOOL)cardBehaviourEnabled {
    if (self.collectionView) {
        return ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled;
    } else {
        return NO;
    }
}

- (BOOL)cardMagicEnabled {
    if (self.collectionView) {
        return ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
    } else {
        return NO;
    }
}

- (NSInteger)numberOfClingingCards {
    if (self.collectionView) {
        return ((CoolCardCollectionView *)self.collectionView).numberOfClingingCards;
    } else {
        return NO;
    }
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    
    NSIndexPath *lastCellIndexPath = [self indexPathForLastCell];
    
    CGFloat bottomYForLastCell = [self bottomYForIndexPath:lastCellIndexPath];
    CGFloat height = self.collectionView.contentInset.top + bottomYForLastCell + self.collectionView.contentInset.bottom;
    
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, height);
    
    return size;
}

- (void)prepareLayout {
    NSMutableDictionary *newLayoutFullInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutFullInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplementaryFullInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSDictionary *cellLayoutInfo = [self cellLayoutInfoForIndexPath:indexPath];
            
            CGFloat currentBottomY = [[cellLayoutInfo objectForKey:@"currentBottomY"] floatValue];
            [self setBottomY:currentBottomY forCellAtIndexPath:indexPath]; // ставим frame ячейке
            
            cellLayoutFullInfo[indexPath] = [self cellLayoutAttributesForCellLayoutInfo:cellLayoutInfo atIndexPath:indexPath];
            
            
            if (!indexPath.item) { // тут создаётся supplementary
                
                if (self.cardBehaviourEnabled) {
                    
                    if (self.cardMagicEnabled) {
                        
                        if (indexPath.section > self.numberOfClingingCards - 1 && indexPath.section == self.lastClingedCardIndex + 1) {
                            
                            [self makeMagicMoveForSupplementaryInfo:&supplementaryFullInfo cellsInfo:&cellLayoutFullInfo beforeSupplementaryViewAtIndexPath:indexPath]; // тут двигаем подъезд карточек друг к другу
                            
                        }
                        
                    }
                    
                }
                
                
                CoolCardLayoutAttributes *supAttributes = [self supplementaryViewLayoutAttributesForCellLayoutAttributes:cellLayoutInfo atIndexPath:indexPath];
                
                supplementaryFullInfo[indexPath] = supAttributes;
                
                
            }
            
            
        }
    }
    
    newLayoutFullInfo[cellReuseIdentifier] = cellLayoutFullInfo;
    newLayoutFullInfo[supplementaryKind] = supplementaryFullInfo;
    
    self.layoutInfo = newLayoutFullInfo;
    
    [self updateNextClingSupplementaryViewIndex];
   // NSLog(@"%f", self.scrollDelta);
    //[self updateKineticInfo];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    for (NSString *key in self.layoutInfo) {
        NSDictionary *attributesDict = [self.layoutInfo objectForKey:key];
        
        for (NSIndexPath *indexKey in attributesDict) {
            
            CoolCardLayoutAttributes *attributes = [attributesDict objectForKey:indexKey];
            
            NSIndexPath *nextKey = [NSIndexPath indexPathForItem:0 inSection:indexKey.section + 1];
            CoolCardLayoutAttributes *nextCardCellAtributes = [attributesDict objectForKey:nextKey];
            
            CGFloat myRelativeY = attributes.frame.origin.y - self.collectionView.contentOffset.y;
            CGFloat nextRelativeY = nextCardCellAtributes.frame.origin.y - self.collectionView.contentOffset.y - [self sizeForSupplementaryViewInSection:indexKey.section + 1].height;

            
            if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) { // тут добавляем decoration
                
                if (self.cardBehaviourEnabled) {
               
                    UICollectionViewLayoutAttributes *decorationLineAttributes = [self decorationLineAttributesForSupplementaryViewAttributes:attributes withIndexPath:indexKey];
                    
                    if (decorationLineAttributes) {
                        [allAttributes addObject:decorationLineAttributes];
                    }
                    
                }
                
                if (CGRectIntersectsRect(rect, attributes.frame) ) {
                    
                    if (self.cardMagicEnabled && self.cardBehaviourEnabled) {
                        if (indexKey.section >= self.lastClingedCardIndex - self.numberOfClingingCards) {
                            [allAttributes addObject:attributes];
                        }
                    } else {
                        [allAttributes addObject:attributes];
                    }
                }
                
            } else {
                /*
                UICollectionViewLayoutAttributes *decorationHideAttributes = [self decorationHideAttributesForAttributes:attributes withIndexPath:indexKey];
                
                if (decorationHideAttributes) {
                    [allAttributes addObject:decorationHideAttributes];
                }
                */
                if (CGRectIntersectsRect(rect, attributes.frame) && attributes.size.height > 0) {
                    if (attributes.isHeader) {
                        if (indexKey.section >= self.lastClingedCardIndex - self.numberOfClingingCards) {
                            [allAttributes addObject:attributes];
                        }
                    } else {
                        if (nextRelativeY + 16 > myRelativeY || !nextCardCellAtributes) {
                            [allAttributes addObject:attributes];
                        }
                    }
                }
                
            }
        }
    }
    
    return allAttributes;
}

- (CoolCardLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoolCardLayoutAttributes *attributes = self.layoutInfo[cellReuseIdentifier][indexPath];
    
    return attributes;
}

- (CoolCardLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    CoolCardLayoutAttributes *attributes = self.layoutInfo[elementKind][indexPath];
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    self.scrollDelta = newBounds.origin.y - self.collectionView.bounds.origin.y;

    if (newBounds.size.width != self.collectionView.bounds.size.width) {
        return YES;
    }
    
    return self.cardBehaviourEnabled;
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

#pragma mark IndexPath

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
    
    NSIndexPath *endIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    
    if ([self isIndexPathValid:indexPath]) {
        return endIndexPath;
    }
    
    return nil;
}

- (NSIndexPath *)nextIndexPathForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == [self indexPathForLastCell]) return nil;
    
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    
    if ([self isTheLastItemInSectionForIndexPath:indexPath]) {
        item = 0;
        
        if (section < [self.collectionView numberOfSections] - 1) {
            section++;
        }
        
    } else {
        item++;
    }
    
    
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSIndexPath *)indexPathForFirstItemInSection:(NSInteger)section {
    if (section > [self.collectionView numberOfSections] - 1) return nil;
    
    return [NSIndexPath indexPathForItem:0 inSection:section];
}

- (NSIndexPath *)indexPathForLastItemInSection:(NSInteger)section {
    if (section > [self.collectionView numberOfSections] - 1) return nil;
    
    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (BOOL)isTheLastItemInSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
}

- (NSIndexPath *)indexPathForLastCell {
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    NSInteger lastSectionIndex = MAX(numberOfSections - 1, 0);
    NSInteger lastItemIndex = MAX(0, [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:lastSectionIndex] - 1);
    
    return [NSIndexPath indexPathForItem:lastItemIndex inSection:lastSectionIndex];
    
}

- (BOOL)isIndexPathValid:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.item < 0) {
        return NO;
    }
    
    if (indexPath.section > [self.collectionView numberOfSections] - 1) return NO;
    
    if (indexPath.item > [self.collectionView numberOfItemsInSection:indexPath.section]) return NO;
    
    return YES;
}

#pragma mark - Clinging

- (BOOL)isCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    return [self.delegate isCellClingingForIndexPath:indexPath];
    
}

- (BOOL)isPreviousCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
    
    if (previousIndexPath.section < 0 || previousIndexPath.item < 0) return NO;
    
    if ([self isCellClingingForIndexPath:previousIndexPath]) {
        return YES;
    }
    
    return NO;
}

// нужно ли?
- (BOOL)isNextCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:indexPath];
    if (!nextIndexPath) return NO;
    
    
    if ([self isCellClingingForIndexPath:nextIndexPath]) {
        return YES;
    }
    
    return NO;
}

- (CGFloat)clingYOffsetForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    return MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingingCards - 1));
}

- (CGFloat)clingYOffsetForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate heightForCellAtIndexPath:indexPath] * indexPath.item + [self sizeForSupplementaryViewInSection:indexPath.section].height;
}

#pragma mark Cling Index

- (void)updateNextClingSupplementaryViewIndex {
    for (NSInteger i = [self.collectionView numberOfSections] - 1; i >= 0; i--) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        
        CGFloat previousBottomY = [self previousBottomYForIndexPath:indexPath];
        CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
        CGFloat clingYOfsset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
        
        if (previousBottomY < collectionViewYOffset + clingYOfsset) {
            self.lastClingedCardIndex = i;
            
            break;
        }
        
    }
}


#pragma mark ZIndex

- (NSInteger)zIndexForIndexPath:(NSIndexPath *)indexPath forViewOfType:(ViewType)viewType {
    
    if (viewType == ViewTypeLineDecorationView) {
        return indexPath.section + 1;
    } else if (viewType == ViewTypeSupplementaryView) {
        return indexPath.section;
    } else if (ViewTypeCell) {
        
        if ([self isCellClingingForIndexPath:indexPath]) {
            return indexPath.section;
        } else {
            return indexPath.section;
        }
        
    }
    
    
    return indexPath.section;
}

#pragma mark - Size

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [self.delegate heightForCellAtIndexPath:indexPath];
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
}

- (CGSize)sizeForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item) return CGSizeZero;
    if (indexPath.section > [self.collectionView numberOfSections] - 1) return CGSizeZero;
    
    if ([self isCellClingingForIndexPath:indexPath]) {
        return CGSizeZero;
    }
    
    
    CGFloat height = [self.delegate heightForSupplementaryViewAtIndexPath:indexPath];
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
    
}

- (CGSize)sizeForSupplementaryViewInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    return [self sizeForSupplementaryViewAtIndexPath:indexPath];
}

#pragma mark - Decorations

- (UICollectionViewLayoutAttributes *)decorationLineAttributesForSupplementaryViewAttributes:(UICollectionViewLayoutAttributes *)supplementaryAttributes withIndexPath:(NSIndexPath *)indexPath {
    
    if (self.lastClingedCardIndex > self.numberOfClingingCards && indexPath.section < self.lastClingedCardIndex) return nil;
    
    if (![self isCardMoreThanScreenForSection:indexPath.section]) return nil;
    
    CGRect supplemetaryViewFrame = supplementaryAttributes.frame;
    
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"bottomLine" withIndexPath:indexPath];
    
    decorationAttributes.frame = CGRectMake(0.0f,
                                            supplemetaryViewFrame.origin.y + supplemetaryViewFrame.size.height,
                                            self.collectionView.bounds.size.width,
                                            6);
    
    decorationAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeLineDecorationView];
    
    
    // --- тут высчитывается alpha

    CGFloat decorationAlpha = (supplementaryAttributes.frame.origin.y - [self previousBottomYForIndexPath:indexPath]) / supplemetaryViewFrame.size.height;

    decorationAlpha = MIN(1, decorationAlpha);
    decorationAttributes.alpha = decorationAlpha;
    
    // --- тут высчитывается alpha
    
    if ([self canShowDecorationViewForCellAttributes:supplementaryAttributes withIndexPath:indexPath andViewType:ViewTypeLineDecorationView]) {
        
        return decorationAttributes;
        
    }
    
    return nil;
}

- (BOOL)canShowDecorationViewForCellAttributes:(UICollectionViewLayoutAttributes *)attributes withIndexPath:(NSIndexPath *)indexPath andViewType:(ViewType)viewType {
    
    CGFloat relativeY = [self relativeYForY:attributes.frame.origin.y];//round(attributes.frame.origin.y - self.collectionView.contentOffset.y);
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    CGFloat supplementaryViewHeight = [self.delegate heightForSupplementaryViewAtIndexPath:indexPath];
    
    if (viewType == ViewTypeLineDecorationView) {
        
        if (relativeY > supplementaryViewHeight + clingYOffset - attributes.size.height / 2.0) {
            
            return NO;
        }
        
        NSIndexPath *nextItemIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section + 1];
        CoolCardLayoutAttributes *nextItemAttributes = [self.layoutInfo[supplementaryKind] objectForKey:nextItemIndexPath];
        
        CGFloat nextRelativeY = [self relativeYForY:nextItemAttributes.frame.origin.y];
        
        if (relativeY > nextRelativeY - attributes.size.height + attributes.size.height / 2.0 && nextItemAttributes) {
            return NO;
        }
        
    }
    
    return YES;
}

#pragma mark - Cell Layout Info

- (NSDictionary *)cellLayoutInfoForIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat previousBottomY = [self previousBottomYForIndexPath:indexPath];
    CGSize cellSize = [self sizeForCellAtIndexPath:indexPath];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    BOOL cellClinging = [self isCellClingingForIndexPath:indexPath];
    
    CGFloat sectionOffset = 0;
    
    if (cellClinging) {
        sectionOffset = self.interClingCellsSpaceY;
    } else {
        sectionOffset = [self isTheLastItemInSectionForIndexPath:indexPath] && indexPath.section != sectionCount-1 ? self.interSectionSpaceY : 0;
    }
    
    
    CGFloat itemOffset = [self isTheLastItemInSectionForIndexPath:indexPath] ? 0 : self.interItemSpaceY;
    
    
    CGSize supplementaryViewSizeForSection = [self sizeForSupplementaryViewInSection:indexPath.section];
    CGSize supplementaryViewSizeForIndexPath = [self sizeForSupplementaryViewAtIndexPath:indexPath]; // может дать CGSizeZero, в этом и смысл
    
    
    CGFloat currentBottomY = previousBottomY + itemOffset + cellSize.height + sectionOffset + supplementaryViewSizeForIndexPath.height;
    
    
    NSDictionary *info = @{@"previousBottomY": [NSNumber numberWithFloat:previousBottomY],
                           @"sectionOffset": [NSNumber numberWithFloat:sectionOffset],
                           @"itemOffset": [NSNumber numberWithFloat:itemOffset],
                           @"supplementaryViewSizeForSection": [NSValue valueWithCGSize:supplementaryViewSizeForSection],
                           @"cellSize": [NSValue valueWithCGSize:cellSize],
                           @"currentBottomY": [NSNumber numberWithFloat:currentBottomY]};
    
    return info;
}

- (CoolCardLayoutAttributes *)cellLayoutAttributesForCellLayoutInfo:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {

    
    // -- start info
    CGSize cellSize = [[cellLayoutInfo objectForKey:@"cellSize"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    
    CGSize supplementaryViewSizeForSection = [[cellLayoutInfo objectForKey:@"supplementaryViewSizeForSection"] CGSizeValue];
    CGSize supplementaryViewSize = indexPath.item ? CGSizeZero : supplementaryViewSizeForSection;

    CGFloat cellY = previousBottomY + supplementaryViewSize.height;
    // -- start info
    
    
    
    CoolCardLayoutAttributes *cellAttributes = [CoolCardLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    cellAttributes.shadowVisible = YES;
    cellAttributes.isHeader = NO;
    
    if (self.cardBehaviourEnabled) {
        
        if ([self isCellClingingForIndexPath:indexPath]) { // если ячейка-хедер
            
            CGFloat newCellY = [self clingedYForViewType:ViewTypeSupplementaryView atY:cellY withIndexPath:indexPath]; // не ошибка, так надо
            
            if (newCellY > cellY) { // если прилепился
                if (indexPath.section > self.numberOfClingingCards - 1) {
                    cellAttributes.shadowVisible = self.cardMagicEnabled;
                }
            } else {
                newCellY += [self topOffsetForIndexPath:indexPath];
            }
            
            cellAttributes.isHeader = YES;
            
            cellY = newCellY;
            
        } else { // если ячейка обычная
            
            cellY = [self clingedYForViewType:ViewTypeCell atY:cellY withIndexPath:indexPath];//[self clingedYForCellAtY:cellY withIndexPath:indexPath];
            
            cellY += [self topOffsetForIndexPath:indexPath];

        
            CGFloat cellRelativeY = [self relativeYForY:cellY];
            CGFloat supRelativeY = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath] + supplementaryViewSizeForSection.height;
            
            
            if (cellRelativeY < supRelativeY) {
                CGFloat offset = supRelativeY - cellRelativeY;
                
                cellY = cellY + offset;
                cellSize = CGSizeMake(cellSize.width, cellSize.height - offset);
                
                cellAttributes.internalYOffset = -offset;
            }
            
            
        }
    
        
    }
    
    cellAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeCell];
    cellAttributes.size = cellSize;
    cellAttributes.center = CGPointMake(cellSize.width / 2.0, cellY + cellSize.height / 2.0);
    return cellAttributes;
    
}

- (CoolCardLayoutAttributes *)supplementaryViewLayoutAttributesForCellLayoutAttributes:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item || [self isCellClingingForIndexPath:indexPath]) return nil;
    
    // -- start info
    CGSize supplementaryViewSize = [[cellLayoutInfo objectForKey:@"supplementaryViewSizeForSection"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    // -- start info
    
    CGFloat supplementaryY = previousBottomY;
    
    
    CoolCardLayoutAttributes *supAttributes = [CoolCardLayoutAttributes layoutAttributesForSupplementaryViewOfKind:supplementaryKind withIndexPath:indexPath];
    supAttributes.size = supplementaryViewSize;
    supAttributes.shadowVisible = YES;
    supAttributes.isHeader = YES;
    
    
    if (self.cardBehaviourEnabled) { // цеплять наверх
        
        CGFloat newSupplementaryY = [self clingedYForViewType:ViewTypeSupplementaryView atY:supplementaryY withIndexPath:indexPath];//[self clingedYForHeaderAtY:supplementaryY withIndexPath:indexPath];
        
        if (newSupplementaryY > supplementaryY) {
            if (indexPath.section > self.numberOfClingingCards - 1) {
                supAttributes.shadowVisible = self.cardMagicEnabled;
            }
        } else {
           newSupplementaryY += [self topOffsetForIndexPath:indexPath];
        }
        
        supplementaryY = newSupplementaryY;
    }
    
    supAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeSupplementaryView];
    supAttributes.center = CGPointMake(supplementaryViewSize.width / 2.0, supplementaryY + supplementaryViewSize.height / 2.0);
    
    return supAttributes;
    
}

#pragma mark - Card Behaviour

- (CGFloat)clingedYForViewType:(ViewType)viewType atY:(CGFloat)startY withIndexPath:(NSIndexPath *)indexPath {
    
    if (self.cardBehaviourEnabled) {
        
        CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
        CGFloat headerYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
        CGFloat fuckOffset = [self fuckOffsetForCardAtSection:indexPath.section];
        
        
        if (viewType == ViewTypeCell) {
            CGFloat cellYOffset = [self clingYOffsetForCellAtIndexPath:indexPath];
            if (startY < collectionViewYOffset + cellYOffset + headerYOffset - fuckOffset) {
                startY = collectionViewYOffset + cellYOffset + headerYOffset - fuckOffset;
            }
        }
        
        
        
        if (viewType == ViewTypeSupplementaryView) {
            
            if (startY < collectionViewYOffset + headerYOffset) {
                startY = collectionViewYOffset + headerYOffset;
            }
            
            if (self.cardMagicEnabled) {
                startY = [self magicYForStartY:startY withIndexPath:indexPath];
            }
        }
        
    }
    
    return startY;
    
}

- (BOOL)isCardMoreThanScreenForSection:(NSInteger)section {
    CGFloat screenHeight = self.collectionView.bounds.size.height;
    
    NSIndexPath *prevLastIndexPath = [self indexPathForLastItemInSection:section - 1]; // Проверить для 0
    NSIndexPath *lastIndexPath = [self indexPathForLastItemInSection:section];
    
    CGFloat firstBottomY = [self bottomYForIndexPath:prevLastIndexPath];
    CGFloat lastBottomY = [self bottomYForIndexPath:lastIndexPath];
    
    BOOL isMore = lastBottomY - firstBottomY > screenHeight;
    
    return isMore;
}

- (CGFloat)fuckOffsetForCardAtSection:(NSInteger)section {

    BOOL isCardBig = [self isCardMoreThanScreenForSection:section];
    CGFloat collectionViewHeight = self.collectionView.bounds.size.height;
    
    CGFloat fuckOffset = 0;
    
    if (isCardBig) {
        NSIndexPath *indexPathForPrevLastCell = [self indexPathForLastItemInSection:section - 1];
        CGFloat bottomPrevCardY = [self bottomYForIndexPath:indexPathForPrevLastCell];
        
        NSIndexPath *indexPathForLastCell = [self indexPathForLastItemInSection:section];
        CGFloat bottomCardY = [self bottomYForIndexPath:indexPathForLastCell];
        
        CGFloat wowNumber = section == [self.collectionView numberOfSections] - 1 ? self.collectionView.bounds.size.height : 100;
        
        fuckOffset = bottomCardY - bottomPrevCardY - collectionViewHeight + wowNumber;
    }
    
    return fuckOffset;
}

- (CGFloat)relativeYForY:(CGFloat)y {
    return y - self.collectionView.contentOffset.y;
}

#pragma mark - Magic

- (CGFloat)magicYForStartY:(CGFloat)startY withIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat magicY = startY;
    NSInteger mIndex = self.lastClingedCardIndex - indexPath.section;
    
    if (indexPath.section < self.lastClingedCardIndex) {
        
        if (mIndex >= self.numberOfClingingCards) { // карта, которую занизили
            magicY += self.clingYOffset * mIndex;
        } else if (mIndex < self.numberOfClingingCards && self.lastClingedCardIndex >= self.numberOfClingingCards) { // поднимать
            
            CGFloat zIndex = 0;
            
            if (indexPath.section < self.numberOfClingingCards - 1) {
                NSInteger wowNumber = self.lastClingedCardIndex - self.numberOfClingingCards;
                zIndex = self.clingYOffset * (mIndex - 1) - wowNumber * self.clingYOffset;
            }
            
            CGFloat offset = (self.clingYOffset * mIndex) - zIndex;
            magicY -= offset;
            
        }
        
    }
    
    return magicY;
    
}

- (void)makeMagicMoveForSupplementaryInfo:(NSMutableDictionary **)supplementaryInfo cellsInfo:(NSMutableDictionary **)cellsInfo beforeSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat supplementaryY = [self previousBottomYForIndexPath:indexPath];
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    CGFloat relativeSupplementaryY = supplementaryY - collectionViewYOffset - clingYOffset;
    
    
    if (relativeSupplementaryY <= self.magicOffset && self.magicOffset >= 0) {
        
        CGFloat delta = MIN((self.magicOffset - (relativeSupplementaryY / self.magicOffset * self.magicOffset)) / 4, self.clingYOffset);
        
        for (int i = 1; i <= self.numberOfClingingCards; i++) {
            
            if (i == self.numberOfClingingCards) {
                delta = -delta;
                
            }
            
            NSIndexPath *previousIndexPathSection = [NSIndexPath indexPathForItem:0 inSection:indexPath.section - i];
            
            if ([self isCellClingingForIndexPath:previousIndexPathSection]) {
                
                CoolCardLayoutAttributes *prevAttributes = (*cellsInfo)[previousIndexPathSection];
                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - delta);
                (*cellsInfo)[previousIndexPathSection] = prevAttributes;
                
            } else {
                
                CoolCardLayoutAttributes *prevAttributes = (*supplementaryInfo)[previousIndexPathSection];
                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - delta);
                (*supplementaryInfo)[previousIndexPathSection] = prevAttributes;
                
            }
            
        }
        
    }
    
    
}

#pragma mark - Top Kinetics

- (BOOL)isScrollTopped {
    return self.collectionView.contentOffset.y < 0;
}

- (CGFloat)topOffsetForIndexPath:(NSIndexPath *)indexPath {

    if (![self isScrollTopped]) return 0;
    
  //  if (indexPath.section > 4) return 0;
    
    NSInteger section = indexPath.section;
    
    return (-self.collectionView.contentOffset.y * section) / 6;
}

#pragma mark - Kinetics



#pragma mark - BottomY Management

- (void)setBottomY:(CGFloat)bottomY forCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *tag = [self tagForIndexPath:indexPath];
    self.cellBottomY[tag] = [NSNumber numberWithFloat:bottomY];
    
}

- (CGFloat)bottomYForIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *tag = [self tagForIndexPath:indexPath];
    return [self.cellBottomY[tag] floatValue];
    
}

- (CGFloat)previousBottomYForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
    NSNumber *tag = [self tagForIndexPath:previousIndexPath];
    
    return [self.cellBottomY[tag] floatValue];
    
}

@end
