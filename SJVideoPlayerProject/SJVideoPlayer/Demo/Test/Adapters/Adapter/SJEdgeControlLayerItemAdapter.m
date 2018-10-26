//
//  SJEdgeControlLayerItemAdapter.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerItemAdapter.h"
#import "SJButtonItemCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJCollectionViewLayout : UICollectionViewLayout
@property (nonatomic, copy, nullable) NSArray<SJEdgeControlButtonItem *> *items;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@end

@implementation SJCollectionViewLayout {
    @private NSMutableArray<UICollectionViewLayoutAttributes *> *_layoutAttributes;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _layoutAttributes = NSMutableArray.array;
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    if ( _scrollDirection == UICollectionViewScrollDirectionHorizontal ) {
        [self _prepareLayout_Horizontal];
    }
    else {
        [self _prepareLayout_Vertical];
    }
}

- (void)_prepareLayout_Horizontal {
    [_layoutAttributes removeAllObjects];
    
    CGFloat content_w = 0; // 内容宽度
    CGRect bounds_arr[_items.count]; // 所有内容的bounds
    int fill_idx = kCFNotFound; // 需要填充的item的索引
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        CGFloat width = 0;
        CGFloat height = 49;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.isHidden ) { }
        else if ( 0 != item.size )
            width = item.size;
        else if ( item.fill )
            fill_idx = i;
        else if ( item.customView )
            width = item.customView.frame.size.width;
        else if ( 0 != item.title.length )
            width = [self sizeWithAttrString:item.title width:CGFLOAT_MAX height:height].width;
        else if ( item.image )
            width = 49;
        
        CGRect bounds = (CGRect){CGPointZero, (CGSize){width, height}};
        content_w += item.insets.left + bounds.size.width + item.insets.right;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    if ( fill_idx != kCFNotFound ) {
        CGFloat max_w = self.collectionView.bounds.size.width;
        if ( max_w > content_w ) bounds_arr[fill_idx] = (CGRect){CGPointZero, (CGSize){max_w - content_w, 49}};
    }
    
    // create `LayoutAttributes`
    CGFloat current_x = 0;
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        SJEdgeControlButtonItem *item = _items[i];
        current_x += item.insets.left;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){(CGPoint){current_x, 0}, (CGSize)bounds_arr[i].size};
        [_layoutAttributes addObject:attributes];
        current_x += bounds_arr[i].size.width + item.insets.right;
    }
}

- (void)_prepareLayout_Vertical {
    [_layoutAttributes removeAllObjects];
    
    CGFloat content_h = 0; // 内容宽度
    CGRect bounds_arr[_items.count]; // 所有内容的bounds
    int fill_idx = kCFNotFound; // 需要填充的item的索引
    
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        CGFloat width = 49;
        CGFloat height = 0;
        SJEdgeControlButtonItem *item = _items[i];
        if ( item.isHidden ) {
        }
        else if ( 0 != item.size )
            height = item.size;
        else if ( item.fill )
            fill_idx = i;
        else if ( item.customView )
            height = item.customView.frame.size.height;
        else if ( 0 != item.title.length )
            height = [self sizeWithAttrString:item.title width:width height:CGFLOAT_MAX].height;
        else if ( item.image )
            height = 49;
        
        CGRect bounds = (CGRect){CGPointZero, (CGSize){width, height}};
        content_h += item.insets.left + bounds.size.width + item.insets.right;
        bounds_arr[i] = bounds;
    }
    
    // 填充剩余空间
    CGFloat max_h = self.collectionView.bounds.size.height;
    if ( fill_idx != kCFNotFound ) {
        if ( max_h > content_h ) bounds_arr[fill_idx] = (CGRect){CGPointZero, (CGSize){49, max_h - content_h}};
    }
    
    CGFloat current_y = floor((max_h - content_h) * 0.5);
    for ( int i = 0 ; i < _items.count ; ++ i ) {
        SJEdgeControlButtonItem *item = _items[i];
        current_y += item.insets.left;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){(CGPoint){0, current_y}, (CGSize)bounds_arr[i].size};
        [_layoutAttributes addObject:attributes];
        current_y += bounds_arr[i].size.height + item.insets.right;
    }
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _layoutAttributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.item >= _layoutAttributes.count ) return nil;
    return _layoutAttributes[indexPath.item];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetMaxX(_layoutAttributes.lastObject.frame), CGRectGetMaxY(_layoutAttributes.lastObject.frame));
}

- (CGSize)sizeWithAttrString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    if ( 0 == attrStr.length ) { return CGSizeZero; }
    CGRect bounds = [attrStr boundingRectWithSize:(CGSize){width, height} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}
@end


@interface SJEdgeControlLayerItemAdapter ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong, readonly) NSMutableArray<SJEdgeControlButtonItem *> *itemsM;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) UICollectionViewScrollDirection direction;
@end

@implementation SJEdgeControlLayerItemAdapter {
    SJCollectionViewLayout *_layout;
}
- (instancetype)initWithDirection:(UICollectionViewScrollDirection)direction {
    self = [super init];
    if ( !self ) return nil;
    _itemsM = NSMutableArray.array;
    
    _layout = [SJCollectionViewLayout new];
    _layout.scrollDirection = direction;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [SJButtonItemCollectionViewCell registerWithCollectionView:_collectionView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    return self;
}
- (UIView *)view {
    return _collectionView;
}
- (void)reload {
    _layout.items = _itemsM;
    [_layout invalidateLayout];
    [_collectionView reloadData];
}
- (void)updateContentForItemWithTag:(SJEdgeControlButtonItemTag)tag {
    NSInteger index = [self indexOfItemForTag:tag];
    SJEdgeControlButtonItem *item = [self itemForTag:tag];
    if ( !item ) return;
    [self _updateContentOfCell:(id)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]] forItem:item];
}
- (NSInteger)numberOfItems {
    return _itemsM.count;
}
- (void)addItem:(SJEdgeControlButtonItem *)item {
    if ( !item ) return;
    [_itemsM addObject:item];
}
- (void)insertItem:(SJEdgeControlButtonItem *)item atIndex:(NSInteger)index {
    if ( !item ) return;
    if ( index >= self.numberOfItems ) index = self.numberOfItems;
    if ( index < 0 ) index = 0;
    [_itemsM insertObject:item atIndex:index];
}
- (void)removeItemAtIndex:(NSInteger)index {
    if ( index < 0 ) return;
    if ( index >= self.numberOfItems ) return;
    [_itemsM removeObjectAtIndex:index];
}
- (nullable SJEdgeControlButtonItem *)itemAtIndex:(NSInteger)index {
    if ( index >= self.numberOfItems ) return nil;
    if ( index < 0 ) return nil;
    return _itemsM[index];
}
- (nullable SJEdgeControlButtonItem *)itemForTag:(SJEdgeControlButtonItemTag)tag {
    for ( SJEdgeControlButtonItem *item in _itemsM ) {
        if ( item.tag != tag ) continue;
        return item;
    }
    return nil;
}
- (NSInteger)indexOfItemForTag:(SJEdgeControlButtonItemTag)tag {
    NSInteger index = kCFNotFound;
    for ( int i = 0 ; i < _itemsM.count ; ++ i ) {
        if ( _itemsM[i].tag != tag ) continue;
        index = i;
        break;
    }
    return index;
}
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2 {
    if ( idx1 < 0 || idx1 >= _itemsM.count ) return;
    if ( idx2 < 0 || idx2 >= _itemsM.count ) return;
    if ( idx1 == idx2 ) return;
    [_itemsM exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}
- (void)exchangeItemForTag:(SJEdgeControlButtonItemTag)tag1 withItemForTag:(SJEdgeControlButtonItemTag)tag2 {
    NSInteger idx1 = [self indexOfItemForTag:tag1];
    NSInteger idx2 = [self indexOfItemForTag:tag2];
    [self exchangeItemAtIndex:idx1 withItemAtIndex:idx2];
}
- (NSInteger)itemCount {
    return _itemsM.count;
}
- (nullable NSArray<SJEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range {
    if ( range.location >= _itemsM.count ) return nil;
    if ( range.location + range.length > _itemsM.count ) return nil;
    return [_itemsM subarrayWithRange:range];
}
- (BOOL)itemsIsHiddenWithRange:(NSRange)range {
    NSArray<SJEdgeControlButtonItem *> *items = [self itemsWithRange:range];
    if ( 0 == items.count ) return YES;
    for ( SJEdgeControlButtonItem *item in items ) {
        if ( !item.isHidden ) return NO;
    }
    return YES;
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJButtonItemCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJButtonItemCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SJEdgeControlButtonItem *item = _itemsM[indexPath.item];
    [self _updateContentOfCell:cell forItem:item];
}

- (void)_updateContentOfCell:(SJButtonItemCollectionViewCell *)cell forItem:(SJEdgeControlButtonItem *)item {
    if ( !item ) return;
    if ( !cell ) return;
    
    if ( item.customView ) {
        cell.button.hidden = YES;
        item.customView.frame = cell.contentView.bounds;
        item.customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:item.customView];
    }
    else if ( 0 != item.title.length  ) {
        cell.button.hidden = NO;
        cell.button.sj_titleLabel.attributedText = item.title;
        cell.button.sj_imageView.image = nil;
    }
    else if ( item.image ) {
        cell.button.hidden = NO;
        cell.button.sj_titleLabel.attributedText = nil;
        cell.button.sj_imageView.image = item.image;
    }
    
    cell.clickedButtonExeBlock = ^(SJButtonItemCollectionViewCell * _Nonnull cell) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ( [item.target respondsToSelector:item.action] ) [item.target performSelector:item.action withObject:item];
#pragma clang diagnostic pop
    };
}
@end
NS_ASSUME_NONNULL_END
