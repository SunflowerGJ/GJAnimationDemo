//
//  NFCScanViewController.m
//  GJAnimationDemo
//
//  Created by GaoJie on 2020/12/15.
//  Copyright © 2020 GJ. All rights reserved.
//

#import "NFCScanViewController.h"
#import "NFCManager.h"
#import "NFCTagManager.h"

@interface NFCScanViewController ()

@property (weak, nonatomic) IBOutlet UITextView *txvContent;

@end

@implementation NFCScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)handleScanNFCUID:(id)sender {
    if (@available(iOS 11.0, *)) {
        __weak typeof(self) weakself=self;

        [[NFCManager sharedInstance] scanTagWithSuccessBlock:^(NFCNDEFMessage * _Nonnull message) {
            NSLog(@"扫描完成：%@",message);
                for(NFCNDEFPayload *payload in message.records){
                    NSLog(@"TNF:%@", [NFCManager getNameFormat:payload.typeNameFormat]);
                    NSLog(@"Type: %@", payload.type.description);
                    NSLog(@"payload: %@", payload.payload.description);
                    NSLog(@"%@",payload.identifier);
                    
                    dispatch_async(dispatch_get_main_queue(),^{

                        NSString *dataStr = [[NSString alloc] initWithData:payload.payload
                                                                              encoding:NSUTF8StringEncoding];
                        
                        NSString *str =[NSString stringWithFormat:@"TNF: %d\nType: %@\nPayload: %@", payload.typeNameFormat, payload.type.description, payload.payload.description];
                        NSLog(@"%@",str);
                        weakself.txvContent.text = [NSString stringWithFormat:@"格式：%@\n内容：%@",[NFCManager getNameFormat:payload.typeNameFormat], dataStr];
                    });
                }
        } andErrorBlock:^(NSError * _Nonnull error) {
            NSLog(@"扫描失败：%@",error.description);
        }];
    } else {
        // Fallback on earlier versions
    }
}
- (IBAction)handleScanNFCMsg:(id)sender {
    __weak typeof(self) weakself=self;

    [[NFCTagManager sharedInstance] scanTagWithSuccessBlock:^(NSString *message) {
        NSLog(@"卡号：%@",message);
        dispatch_async(dispatch_get_main_queue(),^{
            weakself.txvContent.text = [NSString stringWithFormat:@"卡号：%@",message];
        });
        } andErrorBlock:^(NSError * _Nonnull error) {
            
        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
