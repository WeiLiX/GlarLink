//
//  CBPeripheral+MacAddr.m
//  GlarLinkTest
//
//  Created by Wei Li on 2018/12/13.
//  Copyright © 2018 Wei Li. All rights reserved.
//

#import "CBPeripheral+MacAddr.h"

NSString *_macAddress;
NSDictionary *_advertisementData;
NSNumber *_RSSI;

@implementation CBPeripheral (MacAddr)

- (void)setAdvertisementData:(NSDictionary *)advertisementData {
    _advertisementData = [advertisementData copy];
    if ([advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey] != nil)
    {
        NSData *macData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
        
        _macAddress = [NSString stringWithFormat:@"%@",macData];
        _macAddress = [[[_macAddress stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        _macAddress = [_macAddress uppercaseString];
        if (_macAddress.length > 0) {
            _macAddress = [_macAddress substringFromIndex:4];
        }
    }
}

- (NSString *)getMACAddr {
    return _macAddress;
}

- (void)setRSSI:(NSNumber *)rssi {
    _RSSI = [rssi copy];
}

- (NSNumber *)RSSI {
    return _RSSI;
}

@end
