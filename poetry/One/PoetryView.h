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

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

/// 提交
@property (nonatomic, copy) void (^submitBlock)(void);

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


/// 1成功  2失败 其他隐藏
//-(void)setUpState:(NSInteger)state;

///只显示文字背景  不现实显示
-(void)shwoBackground;

@end

NS_ASSUME_NONNULL_END
