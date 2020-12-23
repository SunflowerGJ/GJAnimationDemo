//
//  NFCTagManager.h
//  GJAnimationDemo
//
//  Created by GaoJie on 2020/12/23.
//  Copyright © 2020 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreNFC/CoreNFC.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NFCTagScanSuccessBlock)(NSString *cardNum);
typedef void(^NFCTagScanErrorBlock)(NSError *error);

@interface NFCTagManager : NSObject

@property(nonatomic,copy)NFCTagScanSuccessBlock scanSuccessBlock;
@property(nonatomic,copy)NFCTagScanErrorBlock scanErrorBlock;

+(NFCTagManager *)sharedInstance;
-(void)scanTagWithSuccessBlock:(NFCTagScanSuccessBlock)scanSuccessBlock andErrorBlock:(NFCTagScanErrorBlock)scanErrorBlock;

@end

NS_ASSUME_NONNULL_END
