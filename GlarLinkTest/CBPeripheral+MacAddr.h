//
//  CBPeripheral+MacAddr.h
//  GlarLinkTest
//
//  Created by Wei Li on 2018/12/13.
//  Copyright © 2018 Wei Li. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MacAddr)

- (void)setAdvertisementData:(NSDictionary *)advertisementData;
- (NSString *)getMACAddr;
- (void)setRSSI:(NSNumber *)rssi;

@end

NS_ASSUME_NONNULL_END
