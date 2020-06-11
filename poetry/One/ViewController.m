//
//  ViewController.m
//  poetry
//
//  Created by  GaoGao on 2020/5/22.
//  Copyright © 2020年  GaoGao. All rights reserved.
//


#import "ViewController.h"
#import "IpConfigView.h"
#import "CountDownView.h"
#import "StartView.h"
#import "SubmitView.h"
#import "ConfigHeader.h"
#import "TipsView.h"
#import "WebSocketManager.h"
#import "GCDAsyncUdpSocket.h"
#import "PoetryView.h"

#define SERVERPORT 9600

@interface ViewController ()<WebSocketManagerDelegate,GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong)UIView *scrollview;

@property (nonatomic, strong)IpConfigView *configView;

@property (nonatomic, strong)CountDownView *countDownView;

@property (nonatomic, strong)StartView *startView;

@property (nonatomic, strong)SubmitView *submitView;

@property (nonatomic, strong)TipsView *tipsView;


@property (nonatomic, strong)PoetryView *poetryView;


@property (nonatomic, strong)NSMutableArray *viewArr;

@property (nonatomic, strong)WebSocketManager *webSocketManager;

@property (nonatomic, strong) NSData *address;

@property (nonatomic, assign) float span;

@property (nonatomic, assign) float time;

@property (nonatomic, assign)NSInteger myNumber;

@property (nonatomic, assign) BOOL isFail;

@property (nonatomic, copy)NSString *myID;

/// 1成功  2 失败
@property (nonatomic, assign) NSInteger show;

@end

@implementation ViewController{
    GCDAsyncUdpSocket *receiveSocket;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myNumber = 0;
    
    [self initSocket];
    
 
    
    
    self.configView.frame = self.view.bounds;
    
    [self.view addSubview:self.configView];
    
    
    
    self.countDownView.frame = self.view.bounds;
    [self.view addSubview:self.countDownView];
    
    
    self.startView.frame = self.view.bounds;
    [self.view addSubview:self.startView];
    
    
    
    self.submitView.frame = self.view.bounds;
    [self.view addSubview:self.submitView];
    //    [self.submitView start];
    
    

    
    self.tipsView.frame = self.view.bounds;
    [self.view addSubview:self.tipsView];
    
    
    self.poetryView.frame = self.view.bounds;
    [self.view addSubview:self.poetryView];
    
    
    [self.viewArr addObjectsFromArray:@[self.configView,self.configView,self.countDownView,self.startView,self.submitView,self.tipsView,self.poetryView]];
    
    
    [self operateView:self.configView withState:NO];
    
    
    

    
 
    
    
}




- (void)initSocket {
    
    
    dispatch_queue_t dQueue = dispatch_queue_create("Server queue", NULL);
    receiveSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                  delegateQueue:dQueue];
    NSError *error;
    [receiveSocket bindToPort:SERVERPORT error:&error];
    if (error) {
        NSLog(@"服务器绑定失败");
    }
    [receiveSocket beginReceiving:nil];
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    /**
     *  更新UI一定要到主线程去操作啊
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        
    });
    self.address = address;
    
    //    NSString *sendStr = @"连接成功";
    
    [self sendGroupMessage:msg];
}



/// 像组中发送消息
-(void)sendGroupMessage:(NSString *)message {
    
     NSData *sendData;
    
    if([message isEqualToString:@"poetryNumber"] ){
        NSDictionary *dic =@{
                             @"number":@(self.myNumber),
                             @"type":message
                             };
        
        sendData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    }else{
        sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [receiveSocket sendData:sendData toHost:[GCDAsyncUdpSocket hostFromAddress:self.address]
                       port:[GCDAsyncUdpSocket portFromAddress:self.address]
                withTimeout:60
                        tag:500];
    
    
}


-(void)ceshi:(BOOL)state withView:(UIView *)view {
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.duration=.0001;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:0];
    theAnimation.toValue = [NSNumber numberWithFloat: state ? 3.1415926 : 0.0];
    [view.layer addAnimation:theAnimation forKey:@"animateTransform"];
    
    
}




#pragma mark  websocekt 代理方法


- (void)webSocketDidReceiveMessage:(NSString *)string {
    
    if ([string isEqualToString:@"Success"]) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:string message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
    }else{

        NSDictionary *result = [self dictionaryWithJsonString:string];
        NSDictionary *dataDic = result[@"data"];
        /// ProgramStart logo页 RollQuestion // 321 倒计时 数字滚动页
        // StartAnswer 开始提示页面
        NSString *stepName = dataDic[@"step"];
        
        
        if ([result [@"messageType"]intValue ] == 255&& ![dataDic[@"message"]isKindOfClass:[NSDictionary class]] &&([dataDic[@"message"]isEqualToString:@"重连成功"] || [dataDic[@"message"]isEqualToString:@"注册成功"])) {
            /// 登陆成功
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [al show];
            [self operateView:self.startView withState:NO];
            
        } else if ([result [@"messageType"]intValue ] == 34 &&[stepName isEqualToString:@"step1"]){
            /// 首页
            [self operateView:self.startView withState:NO];
            
            if (!self.isFail) {
              [self sendGroupMessage:@"50"];
            }
           
            
            
        }else if ([result [@"messageType"]intValue ] == 34 &&[stepName isEqualToString:@"step3"]&&!self.isFail){
            
            /// 倒计时 开始
            [self operateView:self.countDownView withState:NO];
            
            [self.countDownView countDownBegin:3];
            
        }else if ([result [@"messageType"]intValue ] == 34 &&[stepName isEqualToString:@"step6"]&&!self.isFail){
            
            /// 验证页面
            [self.poetryView shwoBackground];
            [self operateView:self.poetryView withState:NO];
            
            
        }else if ([result [@"messageType"]intValue ] == 34 &&[stepName isEqualToString:@"step2"]&&!self.isFail){
            
            /// 获取诗词数据
            NSDictionary *data = dataDic[@"data"];
            NSArray *textIndex = data[@"textIndex"];
            NSArray *textArr = data[@"text"];
            
            self.span = [data[@"span"] floatValue];
            
            self.poetryView.textIndex = textIndex;
            self.poetryView.textArr =textArr;
            /// 收到题观众端显示积分页面
//            [self sendGroupMessage:@"60"];
            
        }else if ([result [@"messageType"]intValue ] == 255&& [dataDic[@"message"]isKindOfClass:[NSDictionary class]] &&[dataDic[@"message"][@"message"]isEqualToString:@"抢答成功"]&&!self.isFail){
            /// 抢答结果 成功成功
            
//            [self.tipsView.tipsLabel setTitle:@"抢答成功" forState:UIControlStateNormal];
            
            [self operateView:self.tipsView withState:NO];
            [self sendGroupMessage:@"10"];
            
            
        }else if ([result [@"messageType"]intValue ] == 255&& [dataDic[@"message"]isKindOfClass:[NSDictionary class]] &&[dataDic[@"message"][@"message"]isEqualToString:@"抢答失败"]&&!self.isFail){
            /// 抢答结果 成功失败
           
//            [self.tipsView.tipsLabel setTitle:@"抢答失败" forState:UIControlStateNormal];
//
//            [self operateView:self.tipsView withState:NO];
            
            [self operateView:self.startView withState:NO];
            
            
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[dataDic[@"message"]isEqualToString:@"回答成功"]&&!self.isFail){
            ///回答成功
           
            

            
            self.poetryView.shibai.hidden = YES;
            self.poetryView.chenggong.hidden = NO;
//            self.show= 1;
//             [self.poetryView showAll];
            [self operateView:self.poetryView withState:NO];
            
//            self.myNumber++;
            
//            [self sendGroupMessage:@"poetryNumber"];
            
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[dataDic[@"message"]isEqualToString:@"成功晋级"]&&!self.isFail){
            ///成功晋级
           

            self.poetryView.shibai.hidden = YES;
            self.poetryView.chenggong.hidden = NO;
//            self.show =1;
//             [self.poetryView showAll];
            [self operateView:self.poetryView withState:NO];
            
            self.isFail = YES;
//            [self sendGroupMessage:@"poetryNumber"];
             [self sendGroupMessage:@"20"];
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[dataDic[@"message"]isEqualToString:@"回答失败"]&&!self.isFail){
            ///回答失败
            
            self.poetryView.shibai.hidden = NO;
            self.poetryView.chenggong.hidden = YES;
//            self.show = 2;
//            [self.poetryView showAll];
            [self operateView:self.poetryView withState:NO];
            self.isFail = YES;
            

            [self sendGroupMessage:@"30"];
            
        }else if ([result [@"messageType"]intValue ] == 239){
            /// 重置
            self.isFail = NO;
            [self operateView:self.startView withState:NO];
            /// 法f观众端 观众端
            [self sendGroupMessage:@"50"];
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[dataDic[@"message"]isEqualToString:@"第1行"]&&!self.isFail){
            // 显示第1行
         
            [self operateView:self.poetryView withState:NO];
            [self.poetryView oneAction];
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[dataDic[@"message"]isEqualToString:@"第2行"]&&!self.isFail){
            // 显示第2行
            [self operateView:self.poetryView withState:NO];
            [self.poetryView twoAction];
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[dataDic[@"message"]isEqualToString:@"第3行"]&&!self.isFail){
            // 显示第3行
            [self operateView:self.poetryView withState:NO];
            [self.poetryView threeAction];
            
        }else if ([result [@"messageType"]intValue ] == 32 &&[[NSString stringWithFormat:@"%@",dataDic[@"message"]] containsString:@"总分"]&&!self.isFail){
            // 分数
            NSString *numberStr = [dataDic[@"message"] stringByReplacingOccurrencesOfString:@"总分" withString:@""];
            
            self.myNumber = [numberStr integerValue];
            ///显示分数
            [self sendGroupMessage:@"poetryNumber"];
            
        }
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
}

#pragma mark 设置数字滚动的事件



#pragma mark  隐藏或显示某个view

-(void)operateView:(UIView *)view withState:(BOOL)state {
    
    for (UIView *sub in self.viewArr) {
        
        if (sub == view) {
            sub.hidden = state;
        }else{
            sub.hidden = !state;
        }
        
    }
}



-(IpConfigView *)configView {
    
    
    if (!_configView) {
        _configView = [[[NSBundle mainBundle]loadNibNamed:@"IpConfigView" owner:nil options:nil]lastObject];
        
        @weakify(self)
        _configView.connectBlock = ^(NSString *ID,NSString *mainIP,NSString *listIP,NSString *audienceIP, NSInteger type) {
            @strongify(self)
            
            if( type == 1){
                
                [self.webSocketManager testConnectServerWithIp:mainIP withdeviceID:ID];
                self.myID = ID;
            }else if (type ==2){
                NSDictionary * data = @{@"deviceId":[NSString stringWithFormat:@"%@",ID],@"deviceInfo":ID };
                [self.webSocketManager sendDataToServerWithMessageType:@"0" data:data];
                self.myID = ID;
            }
        };
        
    }
    
    
    return _configView;
}


-(CountDownView *)countDownView {
    
    if (!_countDownView) {
        _countDownView = [[[NSBundle mainBundle]loadNibNamed:@"CountDownView" owner:nil options:nil]lastObject];
        @weakify(self)
        _countDownView.endBlock = ^{
            @strongify(self)
            self.poetryView.shibai.hidden = YES;
            self.poetryView.chenggong.hidden = YES;
//            [self.poetryView setUpState:0];
            [self operateView:self.poetryView withState:NO];
            [self.poetryView scrollWithSpace:self.span];

        };
        
    }
    
    
    return _countDownView;
}



-(StartView *)startView {
    
    if (!_startView) {
        _startView = [[[NSBundle mainBundle]loadNibNamed:@"StartView" owner:nil options:nil]lastObject];
    }
    
    
    return _startView;
}

-(PoetryView *)poetryView {
    
    if (!_poetryView) {
        _poetryView = [[[NSBundle mainBundle]loadNibNamed:@"PoetryView" owner:nil options:nil]lastObject];
        @weakify(self)
//        _poetryView.showEndBlock = ^{
//            @strongify(self)
//            [self operateView:self.submitView withState:NO];
//            [self.submitView start];
//        };
        _poetryView.submitBlock = ^{
            @strongify(self)
            
            NSDictionary *dic = @{
                                  @"name":@"god",
                                  @"age":[NSNumber numberWithInt:[self.myID intValue]],
                                  @"occupation":@"god",
                                  @"img":[NSNull null]
                                  };
            
            
            [self.webSocketManager sendDataToServerWithMessageType:@"80" data:dic];
            
        };
        
//        _poetryView.lineShowEndBlock = ^{
//            @strongify(self)
//            if (self.show == 1) {
//                // 成功
//                self.poetryView.shibai.hidden = YES;
//                self.poetryView.chenggong.hidden = NO;
//            }else if (self.show ==2){
//                // 失败
//                self.poetryView.shibai.hidden = NO;
//                self.poetryView.chenggong.hidden = YES;
//            }
//
//
//        };
    }
    
    
    return _poetryView;
}





-(SubmitView *)submitView {
    
    if (!_submitView) {
        _submitView = [[[NSBundle mainBundle]loadNibNamed:@"SubmitView" owner:nil options:nil]lastObject];
//        @weakify(self)
//        _submitView.submitBlock = ^{
//            @strongify(self)
//
//            NSDictionary *dic = @{
//                                  @"name":@"god",
//                                  @"age":[NSNumber numberWithInt:[self.myID intValue]],
//                                  @"occupation":@"god",
//                                  @"img":[NSNull null]
//                                  };
//
//
//            [self.webSocketManager sendDataToServerWithMessageType:@"80" data:dic];
//
//        };
    }
    
    
    return _submitView;
}




-(NSMutableArray *)viewArr{
    
    if (!_viewArr) {
        _viewArr = [NSMutableArray array];
    }
    return _viewArr;
    
}

-(WebSocketManager *)webSocketManager {
    
    if (!_webSocketManager) {
        _webSocketManager = [WebSocketManager shared];
        _webSocketManager.delegate = self;
    }
    
    return _webSocketManager;
}

-(TipsView *)tipsView {
    
    if (!_tipsView) {
        _tipsView = [[[NSBundle mainBundle]loadNibNamed:@"TipsView" owner:nil options:nil]lastObject];
        
    }
    
    return _tipsView;
}





//// 字符串转字典
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
