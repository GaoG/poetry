//
//  PoetryView.m
//  poetry
//
//  Created by  GaoGao on 2020/5/30.
//  Copyright © 2020年  GaoGao. All rights reserved.
//

#import "PoetryView.h"
#import "ChineseView.h"
#import "NSArray+ErrorHandle.h"
#import "UIView+Category.h"
#import "SNTimer.h"
#import "ConfigHeader.h"
#import "NSArray+ErrorHandle.h"
#define itemWithd 71
#define itemHeight 72

#define lineTimeSpace 0.5f

#define singleTimeSpace 0.1f



@interface PoetryView ()

@property (weak, nonatomic) IBOutlet UIView *chineseBgView;

@property (nonatomic, strong) ChineseView *itemView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSMutableArray *allSub;

@property (nonatomic,strong) SNTimer *gcdTimer;

@property (nonatomic, assign)NSInteger currentIndex;

@property (nonatomic, assign)NSInteger linecurrentIndex;

@property (nonatomic, assign) float space;



@end

@implementation PoetryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)setTextIndex:(NSArray *)textIndex {
    
    _textIndex = textIndex;
    
}

-(void)setTextArr:(NSArray *)textArr {
    
    self.submitButton.enabled = YES;
    
    _textArr = textArr;
    
    
    for (UIView *sub in self.chineseBgView.subviews) {
        
        if ([sub isKindOfClass:[ChineseView class]]) {
            [sub removeFromSuperview];
        }
        
    }
    

    
    
    NSMutableArray *chinese = [NSMutableArray arrayWithCapacity:0];
    NSString *chineseStr =  [_textArr componentsJoinedByString:@""];
//    NSArray *bbb = [aaa componentsSeparatedByString:@""];
    
    for (int i = 0; i<chineseStr.length; i++) {
//        NSString *str = [_textArr objectAtIndexVerify:i];
        
        [chinese addObject:[chineseStr substringWithRange:NSMakeRange(i, 1)]];
    }
    
    
//    NSArray *chinese = [[_textArr componentsJoinedByString:@""] componentsSeparatedByString:@""];
    
    /// 横向
    float Hspace = (self.chineseBgView.width-(14 *itemWithd)-10)/14;
    /// 竖向
    float Sspace = (self.chineseBgView.height-(3*itemHeight))/3;
    
    
    
//    ["十二楼中尽晓妆望仙楼上望君王","曾闻五月到渝州水拍长亭砌下流","人生到处知何似应似非鸿踏雪泥"]
    
    [self.allSub removeAllObjects];
    self.allSub =[[NSMutableArray alloc]initWithCapacity:0];
    [self.dataArr removeAllObjects];
    
    BOOL add = NO;
    for(int i=0; i<chinese.count; i++) {
        
        _itemView = [[[NSBundle mainBundle]loadNibNamed:@"ChineseView" owner:nil options:nil]lastObject];
        
        if ((i>=7&&i<14)||(i>=21&&i<28)||(i>=35&&i<42)) {
            add = YES;
        }else{
            add = NO;
        }
        
        
        _itemView.frame = CGRectMake((i%14)*itemWithd + Hspace *(i%14)+2+(add ? 10 :0), (i/14)*itemHeight + (i/14)*Sspace+10, itemWithd, itemHeight);
        
        _itemView.chineseL.text = [chinese objectAtIndexVerify:i];
        _itemView.chineseL.textColor = UIColor.whiteColor;
        _itemView.chineseL.hidden = YES;
        [self.allSub addObject:_itemView];
        if (i<14) {
            NSArray *oneIdex = [_textIndex objectAtIndexVerify:0];
            for (NSNumber *index in oneIdex) {
                if ([index intValue] == i) {
                    
                    [self.dataArr addObject:_itemView];
//                    _itemView.chineseL.hidden = [oneIdex indexOfObject:index]==0 ? NO :YES;
                }
            }
        }else if (i< 28){
            NSArray *oneIdex = [_textIndex objectAtIndexVerify:1];
            for (NSNumber *index in oneIdex) {
                if ([index intValue] == i-14) {
                    
                    [self.dataArr addObject:_itemView];
                }
            }
            
        }else {
            NSArray *oneIdex = [_textIndex objectAtIndexVerify:2];
            for (NSNumber *index in oneIdex) {
                if ([index intValue] == i-28) {
                    
                    [self.dataArr addObject:_itemView];
                }
            }
            
        }
        
        
        
        [_chineseBgView addSubview:_itemView];
        
    
    }
    
    
}

/// 开始滚动  设置时间
- (void)scrollWithSpace:(float)space {
    
    self.space = space;
    
     space = space<0.001 ? 0.001 : space;
    
   
    [self performSelector:@selector(delayAction) withObject:nil afterDelay:space];
    
    
}

-(void) delayAction{
    
    ChineseView *fristItem = [self.dataArr objectAtIndexVerify:0];
    
    fristItem.chineseL.hidden = NO;
    
    [_gcdTimer invalidate];
    @weakify(self)
    _gcdTimer = [SNTimer repeatingTimerWithTimeInterval:self.space block:^{
        @strongify(self)
        [self updateUI];
    }];
    self.currentIndex = 0;
    [_gcdTimer fire];
    
    
}


-(void)showAll {
    
/// 行显示
//    [self performSelector:@selector(oneAction) withObject:nil afterDelay:lineTimeSpace];
    
    
    /// 逐个显示
//    [_gcdTimer invalidate];
//    @weakify(self)
//    _gcdTimer = [SNTimer repeatingTimerWithTimeInterval:singleTimeSpace block:^{
//        @strongify(self)
//        [self showAction];
//    }];
//    self.linecurrentIndex = 0;
//    [_gcdTimer fire];
    

    
    /// 全显示
//
//    for (ChineseView *sub in self.allSub) {
//        sub.chineseL.hidden = NO;
//    }
    
    
}


-(void)showAction {
    
    ChineseView *old = [self.allSub objectAtIndexVerify:self.linecurrentIndex];
    
    old.chineseL.hidden = NO;
    
    self.linecurrentIndex ++;
    
    if(self.linecurrentIndex == self.allSub.count ){
        [_gcdTimer invalidate];
        self.self.lineShowEndBlock ? self.self.lineShowEndBlock() : nil;
    }
}



-(void)oneAction{
    
//    for (ChineseView *tempItem in self.dataArr) {
//        tempItem.chineseL.hidden = YES;
//    }
    
   
    for (int i=0; i<14; i++) {

        ChineseView *sub = [self.allSub objectAtIndexVerify:i];
        sub.chineseL.textColor = UIColor.blackColor;
        sub.chineseL.hidden = NO;
        
//        i==13 ? [self performSelector:@selector(twoAction) withObject:nil afterDelay:lineTimeSpace] : nil;
    }
    
}


-(void)twoAction{
    
//    for (ChineseView *tempItem in self.dataArr) {
//        tempItem.chineseL.hidden = YES;
//    }
    
    for (int i=14; i<28; i++) {
        
        ChineseView *sub = [self.allSub objectAtIndexVerify:i];
        sub.chineseL.textColor = UIColor.blackColor;
        sub.chineseL.hidden = NO;
        
//        i==27 ? [self performSelector:@selector(threeAction) withObject:nil afterDelay:lineTimeSpace] : nil;
    }
    
}

-(void)threeAction{
//
//    for (ChineseView *tempItem in self.dataArr) {
//        tempItem.chineseL.hidden = YES;
//    }
    
    for (int i=28; i<self.allSub.count; i++) {
        
        ChineseView *sub = [self.allSub objectAtIndexVerify:i];
        sub.chineseL.textColor = UIColor.blackColor;
        sub.chineseL.hidden = NO;
        
//        (i==self.allSub.count-1 && self.lineShowEndBlock) ? self.lineShowEndBlock() : nil;
    }
    
}







-(void)updateUI {
    
    ChineseView *old = [self.dataArr objectAtIndexVerify:self.currentIndex];
    
    old.chineseL.hidden = YES;
    
    self.currentIndex ++;
    
    ChineseView *newV = [self.dataArr objectAtIndexVerify:self.currentIndex];
    
    newV.chineseL.hidden = NO;
    
    
    if(_currentIndex == self.dataArr.count ){
        [_gcdTimer invalidate];
//        self.showEndBlock ? self.showEndBlock() : nil;
            for (ChineseView *tempItem in self.allSub) {
                tempItem.chineseL.hidden = YES;
            }
    }
    
    
}

-(void)shwoBackground {
    for (ChineseView *tempItem in self.allSub) {
        tempItem.chineseL.hidden = YES;
    }
    
}

///// 1成功  2失败 其他隐藏
//-(void)setUpState:(NSInteger)state; {
//    
//    if(state ==1){
//        self.chenggong.hidden = NO;
//        self.chenggong.image = [UIImage imageNamed:@"chenggong"];
//
//    }else if (state ==2){
//        self.chenggong.hidden = NO;
//        self.chenggong.image = [UIImage imageNamed:@"fail"];
//    }else{
//       self.chenggong.hidden = YES;
//    }
//
//
//}


- (IBAction)submitButtonAction:(id)sender {
    
        for (ChineseView *tempItem in self.allSub) {
            tempItem.chineseL.hidden = YES;
        }
    
    self.submitButton.enabled = NO;
    
    [self.gcdTimer invalidate];
    self.submitBlock ? self.submitBlock() : nil;
}



-(NSMutableArray *)dataArr {
    
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataArr;
    
}

@end
