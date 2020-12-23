//
//  NFCManager.m
//  GJAnimationDemo
//
//  Created by GaoJie on 2020/12/15.
//  Copyright © 2020 GJ. All rights reserved.
//

#import "NFCManager.h"

API_AVAILABLE(ios(11.0))
@interface NFCManager ()<NFCNDEFReaderSessionDelegate>{
    BOOL isReading;
}
@property (strong, nonatomic) NFCNDEFReaderSession *session;
@property (strong, nonatomic) NFCNDEFMessage *message;
@end


@implementation NFCManager

#pragma mark - 单例方法
+(NFCManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static NFCManager * sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[NFCManager alloc] init];
    });
    return sSharedInstance;
}
-(void)scanTagWithSuccessBlock:(NFCScanSuccessBlock)scanSuccessBlock andErrorBlock:(NFCScanErrorBlock)scanErrorBlock{
    self.scanSuccessBlock=scanSuccessBlock;
    self.scanErrorBlock=scanErrorBlock;
    isReading=YES;
    [self beginScan];
}
-(void)writeMessage:(NFCNDEFMessage *)message ToTagWithSuccessBlock:(NFCWriteSuccessBlock)writeSuccessBlock andErrorBlock:(NFCWritErrorBlock)writErrorBlock{
    self.message=message;
    self.writeSuccessBlock=writeSuccessBlock;
    self.writErrorBlock=writErrorBlock;
    isReading=NO;
    [self beginScan];
}
+(NFCSupportsStatus)isSupportsNFCReading{
    if (@available(iOS 11.0,*)) {
        if (NFCNDEFReaderSession.readingAvailable == YES) {
            return NFCSupportStatusYes;
        }
        else{
            NSLog(@"%@",@"该机型不支持NFC功能!");
            return NFCSupportStatusDeviceNo;
        }
    }
    else {
        NSLog(@"%@",@"当前系统不支持NFC功能!");
        return NFCSupportStatusnSystemNo;
    }
}
+(NFCSupportsStatus)isSupportsNFCWrite{
    if (@available(iOS 13.0,*)) {
        if (NFCNDEFReaderSession.readingAvailable == YES) {
            return NFCSupportStatusYes;
        }
        else{
            NSLog(@"%@",@"该机型不支持NFC功能!");
            return NFCSupportStatusDeviceNo;
        }
    }
    else {
        NSLog(@"%@",@"当前系统不支持NFC功能!");
        return NFCSupportStatusnSystemNo;
    }
}
-(void)beginScan{
    if (@available(iOS 11.0, *)) {
        self.session = [[NFCNDEFReaderSession alloc]initWithDelegate:self queue:nil invalidateAfterFirstRead:NO];//YES为只读一个TAG然后结束，NO为读取多个
        self.session.alertMessage = @"准备扫描，请将卡片贴近手机";
        [self.session beginSession];
    }
}
//获取类型名数组
+(NSArray*)getNameFormatArray{
    return @[@"Empty",@"NFCWellKnown",@"Media",@"AbsoluteURI",@"NFCExternal",@"Unknown",@"Unchanged"];
}
//获取类型名字
+(NSString*)getNameFormat:(NFCTypeNameFormat)typeName{
    if (typeName==NFCTypeNameFormatEmpty) {
        return @"Empty";
    }
    else if (typeName==NFCTypeNameFormatNFCWellKnown){
        return @"NFCWellKnown";
    }
    else if (typeName==NFCTypeNameFormatMedia){
        return @"Media";
    }
    else if (typeName==NFCTypeNameFormatAbsoluteURI){
        return @"AbsoluteURI";
    }
    else if (typeName==NFCTypeNameFormatNFCExternal){
        return @"NFCExternal";
    }
    else if (typeName==NFCTypeNameFormatUnknown){
        return @"Unknown";
    }
    else if (typeName==NFCTypeNameFormatUnchanged){
        return @"Unchanged";
    }
    return @"";
}
//获取类型结构体
+(NFCTypeNameFormat)getNFCTypeNameFormat:(NSString*)typeName{
    if ([typeName isEqualToString:@"Empty"]) {
        return NFCTypeNameFormatEmpty;
    }
    else if ([typeName isEqualToString:@"NFCWellKnown"]){
        return NFCTypeNameFormatNFCWellKnown;
    }
    else if ([typeName isEqualToString:@"Media"]){
        return NFCTypeNameFormatMedia;
    }
    else if ([typeName isEqualToString:@"AbsoluteURI"]){
        return NFCTypeNameFormatAbsoluteURI;
    }
    else if ([typeName isEqualToString:@"NFCExternal"]){
        return NFCTypeNameFormatNFCExternal;
    }
    else if ([typeName isEqualToString:@"Unknown"]){
        return NFCTypeNameFormatUnknown;
    }
    else if ([typeName isEqualToString:@"Unchanged"]){
        return NFCTypeNameFormatUnchanged;
    }
    return NFCTypeNameFormatEmpty;
}
-(NFCNDEFMessage*)createAMessage{
    NSString* type = @"U";
    NSData* typeData = [type dataUsingEncoding:NSUTF8StringEncoding];
    NSString* identifier = @"12345678";
    NSData* identifierData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    NSString* payload1 = @"ahttps://www.baidu.com";
    NSData* payloadData1 = [payload1 dataUsingEncoding:NSUTF8StringEncoding];
    if (@available(iOS 13.0, *)) {
        NFCNDEFPayload *NDEFPayload1=[[NFCNDEFPayload alloc]initWithFormat:NFCTypeNameFormatNFCWellKnown type:typeData identifier:identifierData payload:payloadData1];
        NFCNDEFMessage* message = [[NFCNDEFMessage alloc]initWithNDEFRecords:@[NDEFPayload1]];
        return message;
    } else {
        return nil;
    }
}
//停止扫描
-(void)invalidateSession{
    if (!self.moreTag) {
        [self.session invalidateSession];
    }
}
#pragma mark - NFCNDEFReaderSessionDelegate
//读取失败回调-读取成功后还是会回调这个方法
- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error API_AVAILABLE(ios(11.0)){
    NSLog(@"%@",error);
    if (error.code == 201) {
        NSLog(@"扫描超时");
    }
    if (error.code == 200) {
        NSLog(@"取消扫描");
    }
}
//读取成功回调iOS11-iOS12
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray*)messages
API_AVAILABLE(ios(11.0)){
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->isReading) {
            if (@available(iOS 11.0, *)) {
                for (NFCNDEFMessage *message in messages) {
                    session.alertMessage = @"读取成功";
                    [self invalidateSession];
                    if (self.scanSuccessBlock) {
                        self.scanSuccessBlock(message);
                    }
                }
            }
        }
        else{
            //ios11-ios12下没有写入功能返回失败
            session.alertMessage = @"写入失败";
            [self invalidateSession];
        }
        
    });
}


//读取成功回调iOS13
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos){
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tags.count>1) {
            session.alertMessage=@"存在多个标签";
            [session restartPolling];
            return;
        }
        id tag=tags.firstObject;
        
        [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
            if (error) {
                session.alertMessage = @"连接NFC标签失败";
                [self invalidateSession];
                return;
            }
            [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                if (error) {
                    session.alertMessage = @"查询NFC标签状态失败";
                    [self invalidateSession];
                    return;
                }
                if (status == NFCNDEFStatusNotSupported) {
                    session.alertMessage = @"标签不是NDEF格式";
                    [self invalidateSession];
                    return;
                }
                if (self->isReading) {
                    //读
                    [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable message, NSError * _Nullable error) {
                        if (error) {
                            session.alertMessage = @"读取NFC标签失败";
                            [self invalidateSession];
                        }
                        else if (message==nil) {
                            session.alertMessage = @"NFC标签为空";
                            [self invalidateSession];
                            return;
                        }
                        else {
                            session.alertMessage = @"读取成功";
                            [self invalidateSession];
                            if (self.scanSuccessBlock) {
                                self.scanSuccessBlock(message);
                            }
                        }
                    }];
                }
                else{
                    //写数据
                    [tag writeNDEF:self.message completionHandler:^(NSError * _Nullable error) {
                        if (error) {
                            session.alertMessage = @"写入失败";
                            if (self.writErrorBlock) {
                                self.writErrorBlock(error);
                            }
                        }
                        else {
                            session.alertMessage = @"写入成功";
                            if (self.writeSuccessBlock) {
                                self.writeSuccessBlock();
                            }
                        }
                        [self invalidateSession];
                    }];
                }
            }];
        }];
    });
}
//
- (void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos){
    
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
