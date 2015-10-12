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
#import "CoolFirstCardCell.h"
#import "CoolCollectionCard.h"
#import "CoolCardItem.h"

@interface CoolFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

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
    
    NSString *title = [sectionData objectAtIndex:indexPath.item];
    
    CoolCardItem *item = [[CoolCardItem alloc] init];
    item.type = CardItemTypeFirst;
    
    UICollectionViewCell <CoolCollectionCard> *cardCell;
    
    for (Class<CoolCollectionCard> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            cardCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
        }
    }
    
    cardCell.layer.zPosition = -1;
    cardCell.title = title;
    
    return cardCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = [self.data allKeys][indexPath.section];
    
    CoolCardSupplementaryCell *supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier forIndexPath:indexPath];
    supCell.title = title;
    supCell.layer.zPosition = indexPath.section;
    supCell.backView.hidden = !!indexPath.section;
    
    return supCell;
}

#pragma mark - UICollectionViewDelegate


#pragma mark - Cells

- (void)registerCells {
    
    self.cellClasses = @[[CoolFirstCardCell class]];
    
    for (Class<CoolCollectionCard> cellClass in self.cellClasses) {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CoolCardSupplementaryCell" bundle:nil] forSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier];
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = @{@"Пара": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры"],
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
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [self registerCells];
    
    
}

@end
