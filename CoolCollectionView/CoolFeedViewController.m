//
//  CoolFeedViewController.m
//  rocketbank
//
//  Created by Vitaly Berg on 29/09/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolFeedViewController.h"

#import "CoolCardCollectionView.h"

#import "CoolCardSupplementaryCell.h"
#import "CollectionCardCell.h"

#import "CoolCollectionCell.h"
#import "CoolCardItem.h"

#import "CoolCardCollectionViewLayout.h"

#import "CoolFirstCardCell.h"
#import "CoolSecondCardCell.h"

@interface CoolFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CardColletionViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet CoolCardCollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellClasses;
@property (strong, nonatomic) NSMutableDictionary *data;

@end

@implementation CoolFeedViewController

static NSString * const cellReuseIdentifier = @"Cell";
static NSString * const viewReuseIdentifier = @"View";

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.data count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *sectionKey = [self.data allKeys][section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    return sectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCardItem *item = [sectionData objectAtIndex:indexPath.item];
    
    NSString *title = item.title;
    
    UICollectionViewCell <CoolCollectionCell> *cell;
    
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
    
    CoolCardSupplementaryCell *supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier forIndexPath:indexPath];
    supCell.title = title;
    supCell.layer.zPosition = indexPath.section;
  //  supCell.backView.hidden = !!indexPath.section;
    
    return supCell;
}

#pragma mark - UICollectionViewDelegate


#pragma mark - Cells

- (void)registerCells {
    
    self.cellClasses = @[[CoolFirstCardCell class],
                         [CoolSecondCardCell class]];
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CoolCardSupplementaryCell" bundle:nil] forSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier];
    
}

#pragma mark - <CardColletionViewLayoutDelegate>

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCardItem *item = [sectionData objectAtIndex:indexPath.item];
    
    if (item.type == CardItemTypeFirst) {
        return 40;
    } else if (item.type == CardItemTypeSecond) {
        return 30;
    }
    
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
                           @"Дыsня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                           @"Дынaя": @[@"Дйййййй", @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"],
                           @"Паsdaра": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"]
                  };
    
    NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in nameDict) {
        NSArray *array = nameDict[key];
        
        NSMutableArray *itemsArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            CoolCardItem *item = [[CoolCardItem alloc] init];
            item.title = array[i];
            item.type = arc4random() % 2 ? CardItemTypeFirst : CardItemTypeSecond;
            
            [itemsArray addObject:item];
        }
        
        itemDict[key] = itemsArray;
    }
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:itemDict];
    
    ((CoolCardCollectionViewLayout *)self.collectionView.collectionViewLayout).delegate = self;
    
    [self registerCells];
    
    
}

@end
