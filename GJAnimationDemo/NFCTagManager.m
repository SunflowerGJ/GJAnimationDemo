//
//  NFCTagManager.m
//  GJAnimationDemo
//
//  Created by GaoJie on 2020/12/23.
//  Copyright © 2020 GJ. All rights reserved.
//

#import "NFCTagManager.h"

API_AVAILABLE(ios(13.0))
@interface NFCTagManager ()<NFCTagReaderSessionDelegate>

@property (strong, nonatomic) NFCTagReaderSession *session;
@property (strong, nonatomic) id<NFCTag> currentTag;

@end

@implementation NFCTagManager

+(NFCTagManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static NFCTagManager * sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[NFCTagManager alloc] init];
    });
    return sSharedInstance;
}
-(void)scanTagWithSuccessBlock:(NFCTagScanSuccessBlock)scanSuccessBlock andErrorBlock:(NFCTagScanErrorBlock)scanErrorBlock{
    self.scanSuccessBlock=scanSuccessBlock;
    self.scanErrorBlock=scanErrorBlock;
    [self beginScan];
}

-(void)beginScan{
    if (@available(iOS 13.0, *)) {
        self.session = [[NFCTagReaderSession alloc] initWithPollingOption:(NFCPollingISO14443 | NFCPollingISO15693 | NFCPollingISO15693) delegate:self queue:dispatch_get_main_queue()];
        self.session.alertMessage = @"准备扫描，请将卡片贴近手机";
        [self.session beginSession];
    } else {
        // Fallback on earlier versions
//        [SVProgressHUD showInfoWithStatus:@"NFC功能只支持iphone7以及iOS13.0以上设备"];
        NSLog(@"NFC功能只支持iphone7以及iOS13.0以上设备");
    }
}

#pragma mark - delegate

-(void)tagReaderSession:(NFCTagReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCTag>> *)tags  API_AVAILABLE(ios(13.0)){
    _currentTag = [tags firstObject];
        NSData *data ;
        if (self.currentTag.type == NFCTagTypeMiFare) {
            id<NFCMiFareTag> mifareTag = [self.currentTag asNFCMiFareTag];
            data = mifareTag.identifier;
        }else if (self.currentTag.type == NFCTagTypeISO15693){
            id<NFCISO15693Tag> mifareTag = [self.currentTag asNFCISO15693Tag];
            data = mifareTag.identifier;
            
        }else{
            self.session.alertMessage = @"未识别出NFC格式";
        }
        
        NSString *hexStr = [self convertDataBytesToHex:data];
        NSString *numStr = [self getNumberWithHex:hexStr];

        self.scanSuccessBlock(numStr);
        //识别成功处理
        
        [session invalidateSession];
}
-(void)tagReaderSession:(NFCTagReaderSession *)session didInvalidateWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){
    self.scanErrorBlock(error);
}
- (NSString *)convertDataBytesToHex:(NSData *)dataBytes {
    
    if (!dataBytes || [dataBytes length] == 0) {
        return @"";
    }
    NSMutableString *hexStr = [[NSMutableString alloc] initWithCapacity:[dataBytes length]];
    [dataBytes enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char *)bytes;
        for (NSInteger i = 0; i < byteRange.length; i ++) {
            NSString *singleHexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([singleHexStr length] == 2) {
                [hexStr appendString:singleHexStr];
            } else {
                [hexStr appendFormat:@"0%@", singleHexStr];
            }
        }
    }];
    return hexStr;
}


/// 从 16 进制字符串中拼出一个8位数“卡号”
/// @param hexStr 16 进制字符串
/// 16 进制字符串需要至少包含 3 个字节
/**
 * 04 c8 cd d2 d2 64 80
 * 卡号这么取：取前三个字节进行处理，高低位按照 [低位][高位] 的顺序处理
 * cd转10进制，不足三位补零，得205
 * c804拼起来转10进制，不足五位补零，得51204
 * 然后两者拼接起来，最终卡号20551204
 */
- (NSString *)getNumberWithHex:(NSString *)hexStr {
    if ([hexStr.lowercaseString hasPrefix:@"0x"]) {
        hexStr = [hexStr substringFromIndex:2];
    }
    if ([hexStr length] < 6) {
        return hexStr;
    }
    
    NSString *byte3 = [hexStr substringWithRange:NSMakeRange(4, 2)]; //低位（第3个字节）
    NSString *byte2 = [hexStr substringWithRange:NSMakeRange(2, 2)]; //高位（第2个字节）
    NSString *byte1 = [hexStr substringWithRange:NSMakeRange(0, 2)]; //低位（第1个字节）
    NSString *tempStr1 = [NSString stringWithFormat:@"%3lu",strtoul([byte3 UTF8String],0,16)]; // 3位数字，不足前置补零
    NSString *tempStr2 = [NSString stringWithFormat:@"%5lu",strtoul([[byte2 stringByAppendingString:byte1] UTF8String],0,16)]; // 5位数字，不足前置补零
    NSString *tempStr = [tempStr1 stringByAppendingString:tempStr2];
    return tempStr;
}

@end
