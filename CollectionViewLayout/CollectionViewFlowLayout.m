//
//  CollectionViewFlowLayout.m
//  CollectionViewLayout
//
//  Created by 田向阳 on 2016/12/20.
//  Copyright © 2016年 田向阳. All rights reserved.
//

#import "CollectionViewFlowLayout.h"
#define itemWidth 167.5
#define SCALE 0.5
@implementation CollectionViewFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
        //设置滚动方向为横向滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //设置单元格的大小
    self.itemSize = CGSizeMake(itemWidth, itemWidth);
        //设置item间距
    self.minimumInteritemSpacing = 5;
    self.minimumLineSpacing = 5;
        //设置左右间距 在collectionView初始位置 和 最后位置保证在也停留在正中间
    self.sectionInset = UIEdgeInsetsMake(0, (self.collectionView.frame.size.width - itemWidth)*SCALE, 0, (self.collectionView.frame.size.width - itemWidth)*SCALE);
}

    //开启实时刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

    // 调整当前layout的样式
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
        //拿到当前视图内的layout组成的数组
    NSArray *temp  =  [super  layoutAttributesForElementsInRect:rect];
    NSMutableArray *attAtrray = [NSMutableArray array];
        //计算出相对于collectionView中心点 collectionView的实际偏移量
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width*0.5;
    for (int i = 0; i < temp.count; i ++) {
        UICollectionViewLayoutAttributes *att = [temp[i] copy]; //做copy操作 消除一下警告
        //计算据两边的cell 距离中间的偏移 取绝对值
        CGFloat offset = ABS(att.center.x - centerX);
            // 计算出scale 并调整 layout的transform属性
        CGFloat scale = 1 - offset / self.collectionView.frame.size.width*0.5;
        att.transform = CGAffineTransformMakeScale(scale, scale);
        
        [attAtrray addObject:att];
    }

    return  attAtrray;

}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGRect  rect;
    
    rect.origin = proposedContentOffset;
    rect.size = self.collectionView.frame.size;
    NSArray *tempArray  = [super  layoutAttributesForElementsInRect:rect];
    CGFloat  gap = 1000;
    CGFloat  a = 0;
    
    for (int i = 0; i < tempArray.count; i++) {
            //判断和中心的距离，得到最小的那个
        UICollectionViewLayoutAttributes *att = tempArray[i];
        gap = ABS(att.center.x - proposedContentOffset.x - self.collectionView.frame.size.width * SCALE);
        if (gap < self.collectionView.frame.size.width *SCALE *SCALE) {
                //同样是计算出左右间距的偏移
            a = att.center.x - proposedContentOffset.x - self.collectionView.frame.size.width * SCALE;
            break;
        }
    }
        //调整x的偏移
    CGPoint  point = CGPointMake(proposedContentOffset.x + a , proposedContentOffset.y);
    return point;
}

    /*
     
     2017-03-09 12:44:11.483 CollectionViewLayout[11131:92643] Logging only once for UICollectionViewFlowLayout cache mismatched frame
     2017-03-09 12:44:11.484 CollectionViewLayout[11131:92643] UICollectionViewFlowLayout has cached frame mismatch for index path <NSIndexPath: 0xc000000000000016> {length = 2, path = 0 - 0} - cached value: {{104.02791666666667, 10.02791666666667}, {167.44416666666666, 167.44416666666666}}; expected value: {{104, 10}, {167.5, 167.5}}
     2017-03-09 12:44:11.484 CollectionViewLayout[11131:92643] This is likely occurring because the flow layout subclass CollectionViewFlowLayout is modifying attributes returned by UICollectionViewFlowLayout without copying them
     
     */

@end
