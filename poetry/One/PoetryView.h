//
//  PoetryView.h
//  poetry
//
//  Created by  GaoGao on 2020/5/30.
//  Copyright © 2020年  GaoGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PoetryView : UIView


@property (weak, nonatomic) IBOutlet UIImageView *shibai;
@property (weak, nonatomic) IBOutlet UIImageView *chenggong;

@property (nonatomic, strong)NSArray *textArr;

@property (nonatomic, strong)NSArray *textIndex;

/// 单个显示完毕
@property (nonatomic, copy)void (^showEndBlock) (void);


/// 行显示完毕
@property (nonatomic, copy)void (^lineShowEndBlock) (void);


/// 开始滚动  设置时间
- (void)scrollWithSpace:(float)space;

/// 
-(void)showAll;

/// 显示0行
-(void)oneAction;


/// 显示1行
-(void)twoAction;

/// 显示2行
-(void)threeAction;

@end

NS_ASSUME_NONNULL_END
