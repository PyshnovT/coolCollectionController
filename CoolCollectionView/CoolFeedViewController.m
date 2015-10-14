//
//  CoolFeedViewController.m
//  rocketbank
//
//  Created by Vitaly Berg on 29/09/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolFeedViewController.h"

#import "CoolCardCollectionView.h"

#import "CoolDateSup.h"
#import "CollectionCardCell.h"

#import "CoolCollectionCell.h"
#import "CoolCellItem.h"

#import "CoolCardCollectionViewLayout.h"

#import "CoolFirstCardCell.h"
#import "CoolSecondCardCell.h"
#import "CoolEmptyCell.h"

#import "CoolSupplementaryItem.h"
#import "CoolCollectionSupplementaryView.h"
#import "CoolNoteSup.h"



@interface CoolFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CardColletionViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet CoolCardCollectionView *collectionView;

@property (nonatomic, strong) NSArray *cellClasses;
@property (nonatomic, strong) NSArray *supplementaryClasses;

@property (strong, nonatomic) NSMutableDictionary *data;

@end

@implementation CoolFeedViewController

static NSString * const supplementaryKind = @"Head";

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.data count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *sectionKey = [self.data allKeys][section];
    
    if ([sectionKey hasPrefix:@"УВЕДОМЛЕНИЕ"]) return 1;
    
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    return sectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    
   // NSLog(@"KEY: %@", sectionKey);
    
    if ([sectionKey hasPrefix:@"УВЕДОМЛЕНИЕ"]) {
        CoolEmptyCell *emptyCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CoolEmptyCell class]) forIndexPath:indexPath];
        
        return emptyCell;
    }
    
    
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCellItem *item = [sectionData objectAtIndex:indexPath.item];
    
    NSString *title = item.title;
    
    UICollectionViewCell<CoolCollectionCell> *cell;
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
        }
    }
    
    cell.layer.zPosition = -2;
    cell.title = title;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = [self.data allKeys][indexPath.section];
    
    NSLog(@"SUPVIEW %@", title);

    
    CoolSupplementaryItem *item = [[CoolSupplementaryItem alloc] init];
    
    NSString *section = [[self.data allKeys] objectAtIndex:indexPath.section];
    
    if ([section hasPrefix:@"УВЕДОМЛЕНИЕ"]) {
        item.type = SupItemTypeNote;
    } else {
        item.type = SupItemTypeDate;
    }
    
    NSLog(@"секция:    %@", section);
    
    
    UICollectionViewCell<CoolCollectionSupplementaryView> *supCell;
    
    for (Class<CoolCollectionSupplementaryView> supClass in self.supplementaryClasses) {
        if ([supClass handleItem:item]) {
           // NSLog(@"%@", NSStringFromClass(supClass));
            supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:supplementaryKind withReuseIdentifier:NSStringFromClass(supClass) forIndexPath:indexPath];
    //        supCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(supClass) forIndexPath:indexPath];
            
            if (supClass == [CoolDateSup class]) {
                ((CoolDateSup *)supCell).title = title;
            }
        }
    }
    

    supCell.layer.zPosition = indexPath.section;

    return supCell;
}

#pragma mark - UICollectionViewDelegate


#pragma mark - Registering cells

- (void)registerCells {
    
    self.cellClasses = @[[CoolFirstCardCell class],
                         [CoolSecondCardCell class]
                         ];
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CoolEmptyCell class]) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass([CoolEmptyCell class])];
    
    self.supplementaryClasses = @[[CoolNoteSup class],
                                  [CoolDateSup class]
                         ];
    
    for (Class<CoolCollectionSupplementaryView> supClass in self.supplementaryClasses) {
   //     [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(supClass) bundle:nil]  forSupplementaryViewOfKind:NSStringFromClass(supClass) withReuseIdentifier:NSStringFromClass(supClass)];
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(supClass) bundle:nil]  forSupplementaryViewOfKind:supplementaryKind withReuseIdentifier:NSStringFromClass(supClass)];
    }
    
}

#pragma mark - <CardColletionViewLayoutDelegate>

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    
    if ([sectionKey hasPrefix:@"УВЕДОМЛЕНИЕ"]) return 0;
    
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCellItem *item = [sectionData objectAtIndex:indexPath.item];
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            return [cellClass heightOfCell];
        }
    }
    
    return 0;
}

- (CGFloat)heightForSupplementrayViewAtIndexPath:(NSIndexPath *)indexPath {
    /*
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    
    CoolSupplementaryItem *item = [sectionData objectAtIndex:indexPath.section];
    
    for (Class<CoolCollectionSupplementaryView> supClass in self.supplementaryClasses) {
        if ([supClass handleItem:item]) {
            return [supClass heightOfCell];
        }
    }
    */
    return 0;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *nameDict = @{@"Пара": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры"],
                               @"Вата": @[@"Ва", @"Вы", @"Вивы"],
                               @"Дыня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Тёрка": @[@"Твац", @"Тцуацуа"],
                               @"Чdучмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучaмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чуaчмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучaмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Дaыня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Дыgня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"УВЕДОМЛЕНИЕ 3": @[@""],
                               @"УВЕДОМЛЕНИЕ 7": @[@"", @"", @""],
                               @"Дыsня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Дынaя": @[@"Дйййййй", @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"],
                               @"Паsdaра": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"],
                               @"Wow": @[@"Wo"]
                               };
    
    NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in nameDict) {
        
        if ([key hasPrefix:@"УВЕДОМЛЕНИЕ"]) {
            itemDict[key] = [NSNull null];
        } else {
        
            NSArray *array = nameDict[key];
            
            NSMutableArray *itemsArray = [NSMutableArray array];
            
            for (int i = 0; i < array.count; i++) {
                
                
                CoolCellItem *item = [[CoolCellItem alloc] init];
                item.title = array[i];
                item.type = arc4random() % 2 ? CellItemTypeFirst : CellItemTypeSecond;
                
                [itemsArray addObject:item];
            }
            
            itemDict[key] = itemsArray;
        }
    }
    
    NSLog(@"%@", itemDict);
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:itemDict];
    
    ((CoolCardCollectionViewLayout *)self.collectionView.collectionViewLayout).delegate = self;
    
    [self registerCells];
    
    
}

@end
