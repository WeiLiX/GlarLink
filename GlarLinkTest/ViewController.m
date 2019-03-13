//
//  ViewController.m
//  GlarLinkTest
//
//  Created by Wei Li on 2018/12/12.
//  Copyright © 2018 Wei Li. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+MacAddr.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *testModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *microphoneDataSwitch;
@property (nonatomic, strong) CBCentralManager *centralManager;
//@property (nonatomic, strong) CBPeripheral *peripheral;
//@property (nonatomic, strong) CBCharacteristic *timeCharacteristic;
//@property (nonatomic, strong) CBCharacteristic *dataCharacteristic;
@property (nonatomic, strong) NSMutableArray *perpherralList;
@property (nonatomic, strong) NSMutableDictionary *peripheralDictionary;

@end

#define INSULINK_NAME                       @"NNinsulinK"
#define INSULINKBL_NAME                     @"insulinKBL"
#define INSULINK_SERVICE_UUID               @"00D0"
#define INSULINK_CHARACTER_INSULINK         @"D003"
#define INSULINK_CHARACTER_RESPONSE         @"D002"
#define INSULINK_CHARACTER_TIME             @"D001"
#define INSULINK_DATA_PACKAGE_PREFIX        @"444e"
#define INSULINK_DATA_CMD                   0x03
#define INSULINK_DATA_DELETE_CMD            0x04
#define INSULINK_DATA_WAVE_CMD              0xF1
#define INSULINK_DATA_WAVE_CMD_FINAL        0xF2
#define INSULINK_SET_TEST_MODEL_CMD         0xF3
#define INSULINK_KEY_STATE_CMD              0xF4
#define INSULINK_SET_MICROPHONE_STATE_CMD   0xF5

static NSString *peripheral_key = @"Peripheral";
static NSString *characteristic_time_key = @"Characteristic_Time";
static NSString *characteristic_data_key = @"Characteristic_Data";
static NSString *peripheral_macaddr_key = @"peripheral_macaddr";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.perpherralList = [NSMutableArray new];
    self.peripheralDictionary = [NSMutableDictionary new];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    self.logView.layoutManager.allowsNonContiguousLayout = NO;
    [self.testModeSwitch setOn:NO];
    
//    [self readData:@"444e4ef10f0041030f001a000a00c3001300050009000701150002000f0069001d0032001b0001000100010002000700010004000300050001000600100049000f0003020400f71c120032000300000095"];      //6
//    [self readData:@"444e92f1090033000f00800a09008e06090036070700b3010a005f080700b40109006c00060056000300320029005a0007007b00140006000c008c000c0008000b00680016002c00120014001800020001000400030001001a00190013002500080001000800400008004b000300050001000100060046000600d8000e00e00b1000161104009a010600cd0011000e0000000000f6"];      //12
//    [self readData:@"444e62f10600c6041a000c0011009d022a00d000060017000b00710005000700160002000e00040002000b000a0001002400030003000e0003000100040007000100050017003400180055001b00a9000d00911b07006f000a000f00130033000000000031"];      //8
//    [self readData:@"444e76f1040042000400ad0103008400010009040500ff001a0018020f0002000d003d010f0003000d0083001b0057000100030001001d000b000a000c00a200120004000a00b0001a000a000a009a00150005000d00ab0020009300100003000c008d000c0003000b000300040007000e00ffff000000007e"];      //11
//    [self readData:@"444e9ef109005b0e0200020007005206060019031f0028000d00f702160013000c006d010e00060011008b001a006d0001000d001c00670009000f001b005d0019006600080006000d005c00070002000f004b0017004a001400410013003a0010002d000f002e00160028001400290012002e0014002700130002000c000a001f00320012002a00100014000e00170a0200c01a0800cc0013001400000000007c"];      //22
//    [self readData:@"444e7ef107003e050700790307003602140066000d004003130008000d003b012100780019006a00170094001c00de00170095000a00ac001900d5000f009f000b00bc001100bf031300a80302004d03020043180700100014000e001f00050005000c0007002b001100040017000b0003000e00010047000f002a0000000000d8"];      //12
//    [self readData:@"444e76f10600ae030d0003000f00ac021000f70013009d000f006c0014007b001b00f2000f009c00120095000f0097001600970001000b0015009c00020001001900a2001100a7001200b4001c00b8001700a30017009000100073000d006a001300ffff1300250008000b000900050009000a000500000008"];      //20
//    [self readData:@"444e8af106005e03150024001100660211002a000c0088010e00050007008a000e000b0006007c0006000f0006008000080014001100e400110010000f00aa0016000c000d00c90012001b000c00970011000a000e00bc00110006000e009a0020009d0010000c000e008a0011000c000c0085001e0067001400a3010d00ffff07006b000f002e0000000000ab"];      //16
//    [self readData:@"444ea2f1180080010d00bd060c008300160046000d003803110041000d001a010f001700070094000f000d000f00730012000b000e00aa000d0010000e00c700100014000b00cc001a001c000c00aa00110014000f00d70017000d000c007d000400010001002c00130012000d00ba00190009000c00a600150043000e00df0016001b000e00a7001a0004000d00a40016001a000d0094000f00ffff0f0001010000000049"];      //17
//    [self readData:@"444e8ef10500a80104000900030002000400020517000600050077060c00140006007c030f0011000d002001140074001000590013006e00110086001100770019007f001b00b9000c000400090085001900c4001400a8001800b0001000940009006a010c00ffff170009000a00090001000100020001000a0020000100020001000e00010061000d00040000000000e1"];      //15
//    [self readData:@"444e9af10f000400010027070e001700080025011d00c60012004a000f001e00100019001200070003000d0001000d0001000100120027000f0027000f0020000400050002000200020007001300370013004500150049000f00470009004a000e003f000f003e000f003b000d00340012002e00120039000c0033000d003c000a0043000c00ffff0800960006009700060022000d000300000000004d"];      //24
//    [self readData:@""];      //
}

- (IBAction)btnClicked:(id)sender {
    [self logText:@"点击按钮Tag：%ld", [sender tag]];
    switch ([sender tag]) {
        case 1000:
            [self.perpherralList removeAllObjects];
            [self.tableView reloadData];
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:INSULINK_SERVICE_UUID]] options:nil];
            break;
        case 1001:
            [self.logView setText:@""];
            break;
        default:
            break;
    }
}

- (void)setMicrophoneDataState:(BOOL)state WithPeripheral:(CBPeripheral *)peripheral {
    NSString *data;
    if (state) {
        data = @"03F001";
    } else {
        data = @"03F000";
    }
    NSInteger checksum = [self checkSum:data];
    data = [NSString stringWithFormat:@"%@%@%@", INSULINK_DATA_PACKAGE_PREFIX, data, [self ToHex:checksum]];
    [self logText:@"设备log控制：%@", data];
    NSData *bytes = [self hexToBytes:data];
    NSMutableDictionary *info = self.peripheralDictionary[peripheral.identifier.UUIDString];
    [self writeCharacteristic:peripheral characteristic:info[characteristic_time_key] value:bytes];
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell"];
    CBPeripheral *peripheal = [self.perpherralList objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[peripheal getMACAddr]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", peripheal.RSSI]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.perpherralList count];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.perpherralList objectAtIndex:indexPath.row];
//    if (peripheral.state == CBPeripheralStateConnected) {
//        [self logText:@"该设备已经绑定过");
//        return;
//    }
    [self.centralManager connectPeripheral:peripheral options:nil];
//     connectPeripheral: CompletionBlock:^(BOOL success, NSError *error) {
//        if (success) {
//        }else{
//            if (error) {
//                NSString *text = [NSString stringWithFormat:@"连接失败--原因:%@",error.localizedDescription];
//                [self logText:@"%@", text);
//                // 连接失败或断开连接继续扫描进行重连
//                [self.centralManager reScan];
//            }
//        }
//    }];
}

/** 判断手机蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        [self logText:@"蓝牙可用"];
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:INSULINK_SERVICE_UUID]] options:nil];
    }
    if(central.state==CBManagerStateUnsupported) {
        [self logText:@"该设备不支持蓝牙"];
    }
    if (central.state==CBManagerStatePoweredOff) {
        [self logText:@"蓝牙已关闭"];
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 对外设对象进行强引用
//    self.peripheral = peripheral;
    
    if ([peripheral.name isEqualToString:INSULINK_NAME]) {
        // 可以根据外设名字来过滤外设
//        self.peripheral = peripheral;
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:peripheral forKey:peripheral_key];
        [peripheral setAdvertisementData:advertisementData];
        [info setObject:peripheral.getMACAddr forKey:peripheral_macaddr_key];
        [self.peripheralDictionary setObject:info forKey:peripheral.identifier.UUIDString];
        [self logText:@"发现符合要求的外设"];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
    // 连接外设
//    if (peripheral.state != CBPeripheralStateConnected) {
//        [self.centralManager connectPeripheral:peripheral options:nil];
//    } else {
//        [self logText:@"发现设备：%@", peripheral.name);
//    }
//    [peripheral setAdvertisementData:advertisementData];
//    [peripheral setRSSI:RSSI];
//    [self.perpherralList addObject:peripheral];
//    [self.tableView reloadData];
}

/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    // 可以停止扫描
//    [self.centralManager stopScan];
    
    if (![[self.peripheralDictionary allKeys] containsObject:peripheral.identifier.UUIDString]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:peripheral forKey:peripheral_key];
        [self.peripheralDictionary setObject:info forKey:peripheral.identifier.UUIDString];
    }
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:nil];
    [self logText:@"连接成功"];
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self logText:@"连接失败:%@", error.localizedDescription];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:INSULINK_SERVICE_UUID]] options:nil];
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    [self logText:@"断开连接:%@", error.localizedDescription];
    // 断开连接可以设置重新连接
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        [self logText:@"所有的服务：%@",service.UUID];
    }
    
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:nil forService:service];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    NSMutableDictionary *info = self.peripheralDictionary[peripheral.identifier.UUIDString];
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
//        [self logText:@"所有特征：%@", characteristic];
        if ([characteristic.UUID.UUIDString isEqualToString:INSULINK_CHARACTER_TIME]) {
            [info setObject:characteristic forKey:characteristic_time_key];
            if (_testModeSwitch.isOn) {
                NSString *data = [NSString stringWithFormat:@"03%02x%02x", INSULINK_SET_TEST_MODEL_CMD, 0x01];
                NSInteger checksum = [self checkSum:data];
                data = [NSString stringWithFormat:@"%@%@%@", INSULINK_DATA_PACKAGE_PREFIX, data, [self ToHex:checksum]];
                [self logText:@"测试模式数据：%@", data];
                [self logText:@"请按下按键测试"];
                NSData *bytes = [self hexToBytes:data];
                [self writeCharacteristic:peripheral characteristic:characteristic value:bytes];
            } else {
                [self setMicrophoneDataState:self.microphoneDataSwitch.isOn WithPeripheral:peripheral];
                [self writeTimeWithPeripheral:peripheral];
            }
        } else if ([characteristic.UUID.UUIDString isEqualToString:INSULINK_CHARACTER_RESPONSE]) {
            [info setObject:characteristic forKey:characteristic_data_key];
//            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
//    self.characteristic = service.characteristics.lastObject;
    
    // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
//    [peripheral readValueForCharacteristic:self.characteristic];
    
    // 订阅通知
//    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        [self logText:@"订阅失败"];
        [self logText:@"%@",error];
    }
    if (characteristic.isNotifying) {
        [self logText:@"订阅成功"];
    } else {
        [self logText:@"取消订阅"];
    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
//    NSData *data = characteristic.value;
//    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    [self logText:@"收到外围设备数据：%@", characteristic.UUID];
//    if (characteristic.value.length > 0) {
//        Byte *data = (Byte *)[characteristic.value bytes];
//        for (int index = 0; index < characteristic.value.length; index++) {
//            Byte value = 0;
//            [characteristic.value getBytes:&value range:NSMakeRange(index, 1)];
//            NSLog(@"数据：%02x", value);
//        }
//    }
    NSString *str = [NSString stringWithFormat:@"%@",characteristic.value];
    str = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
//    Byte *data = (Byte *)[characteristic.value bytes];
    [self logText:@"收到数据：%@", str];
    
    if (self.testModeSwitch.isOn) {
        [self readTestData:str WithPeripheral:peripheral];
    } else {
        [self readData:str WithPeripheral:peripheral];
    }
}

- (void)readTestData:(NSString *)dataStr WithPeripheral:(CBPeripheral *)peripheral {
    if ([dataStr rangeOfString:@"f3"].location == 6) {
        [self logText:@"蓝牙正常\n请按下按键"];
    } else if ([dataStr rangeOfString:@"f4"].location == 6){
        [self logText:@"按键正常\n请发出声音测试麦克风"];
        NSString *data = [NSString stringWithFormat:@"03%02x%02x", INSULINK_SET_MICROPHONE_STATE_CMD, 0x01];
        NSInteger checksum = [self checkSum:data];
        data = [NSString stringWithFormat:@"%@%@%@", INSULINK_DATA_PACKAGE_PREFIX, data, [self ToHex:checksum]];
        [self logText:@"打开microphone数据：%@", data];
        NSData *bytes = [self hexToBytes:data];
        NSMutableDictionary *info = self.peripheralDictionary[peripheral.identifier.UUIDString];
        [self writeCharacteristic:peripheral characteristic:info[characteristic_time_key] value:bytes];
    }
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error == nil) {
        [self logText:@"写入成功"];
    } else {
        [self logText:@"写入失败：%@", error.localizedDescription];
    }
}

///** 读取数据 */
//- (IBAction)didClickGet:(id)sender {
//    [self.peripheral readValueForCharacteristic:self.characteristic];
//}
//
///** 写入数据 */
//- (IBAction)didClickPost:(id)sender {
//    // 用NSData类型来写入
//    NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
//    // 根据上面的特征self.characteristic来写入数据
//    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
//}

#pragma mark - CustomFunction
// 写入时间
- (void)writeTimeWithPeripheral:(CBPeripheral *)peripheral{
    long long time = [[NSDate date] timeIntervalSince1970];
    NSString *timeStr = [self ToHex:time];
    NSInteger len = 1+4+1;
//    timeStr = [self reverseHexStringForInsulink:timeStr];
    timeStr = [self ToHex:[self readTime:timeStr]];
    NSString *dataStr = [NSString stringWithFormat:@"%@%@01%@", INSULINK_DATA_PACKAGE_PREFIX, [self ToHex:len], timeStr];
    dataStr = [NSString stringWithFormat:@"%@%0x", dataStr, (int)[self checkSum:[dataStr substringFromIndex:4]]];
    NSData *data = [self hexToBytes:dataStr];//[self hexTimeToBytes:dataStr];
    NSString *text = [NSString stringWithFormat:@"写入时间:%@--%@",[self getFullStringFromDate:time], dataStr];
    [self logText:@"%@", text];
    NSMutableDictionary *info = self.peripheralDictionary[peripheral.identifier.UUIDString];
    [self writeCharacteristic:peripheral characteristic:info[characteristic_time_key] value:data];
}

- (NSString *)getFullStringFromDate:(long long)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSString *)reverseHexStringForInsulink:(NSString *)hexStr {
    NSString *convertString = @"";
    NSInteger len = hexStr.length / 2;
    
    for (NSInteger i = 0; i <= len; i++) {
        convertString = [NSString stringWithFormat:@"%@%@", convertString, [hexStr substringWithRange:NSMakeRange((len - i) * 2, 2)]];
    }
    
    return convertString;
}

// 16进制字符串转为NSData
- (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx <= (int)str.length - 2; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

// 16进制时间字符串转为NSData
- (NSData *)hexTimeToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = (int)str.length - 2; idx >= 0; idx -= 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

// 10进制转为16进制字符串
- (NSString *)ToHex:(long long)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    int ttmpig;
    for (int i = 0; i < 9; i++) {
        ttmpig = tmpid % 16;
        tmpid = tmpid / 16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    //不够一个字节凑0
    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
}

//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前两个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                                = 0x01,
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                    = 0x08,
     CBCharacteristicPropertyNotify                                                    = 0x10,
     CBCharacteristicPropertyIndicate                                                = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
     CBCharacteristicPropertyExtendedProperties                                        = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)    = 0x200
     };
     
     */
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSString *text = [NSString stringWithFormat:@"该字段不可写！"];
        [self logText:@"%@", text];
    }
}

// 读取时间
- (long long)readTime:(NSString *)str{
    
    NSString *timeHexStr = @"";
    // 传过来的是逆序的,需要调整再转换
    for (int i = (int)str.length - 2; i >= 0; i -= 2) {
        NSString *temp = [str substringWithRange:NSMakeRange(i, 2)];
        timeHexStr = [timeHexStr stringByAppendingString:temp];
    }
    
    long long result = strtoul([timeHexStr UTF8String], 0, 16);
    //    [self logText:@"读取到时间:%@",[self getFullStringFromDate:result]);
    return result;
}

- (NSInteger)checkSum:(NSString *)strData {
    NSInteger sum = 0;
    NSInteger startIndex = 0;
    NSInteger len = strData.length / 2;
    
    for (NSInteger i = 0; i < len; i++) {
        NSString *str = [strData substringWithRange:NSMakeRange(startIndex, 2)];
        NSInteger value = strtoul([str UTF8String], 0, 16);
        sum += value;
        startIndex += 2;
    }
    return (sum & 0xff);
}

- (void)readData:(NSString *)dataString WithPeripheral:(CBPeripheral *)peripheral {
    if ([dataString hasPrefix:INSULINK_DATA_PACKAGE_PREFIX]) {      //校验数据包以444e开头
        NSString *dataLenStr = [dataString substringWithRange:NSMakeRange(4, 2)];
        NSInteger dataLen = strtol([dataLenStr UTF8String], 0, 16);
//        [self logText:@"数据长度:%@---%ld", dataLenStr, dataLen];
        NSInteger allLen = dataLen * 2 + 4 + 2;
        if ([dataString length] != allLen) {
            [self logText:@"数据长度错误：%ld，实际长度：%ld", allLen, dataString.length];
            return;
        }
        
        //校验数据格式
        NSInteger sum = [self checkSum:[dataString substringWithRange:NSMakeRange(4, allLen-6)]];
        NSInteger verify = strtol([[dataString substringWithRange:NSMakeRange(allLen - 2, 2)] UTF8String], 0, 16);
        if (sum != verify) {
            [self logText:@"数据校验失败：%ld, verify：%ld", sum, verify];
        }
        
        NSInteger cmd = strtol([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String], 0, 16);
        if (cmd == INSULINK_DATA_CMD) {
            dataLen -= 2;
            NSInteger dataCount = dataLen / 6;
            NSMutableArray *ret = [NSMutableArray new];
            NSMutableArray *sequenceIds = [NSMutableArray new];
            NSInteger startIndex = 8;
            if (dataCount == 0) {       //没有数据结束处理
                return;
            }
            [self logText:@"dataCount:%ld", dataCount];
            for (NSInteger i = 0; i < dataCount; i++) {
                NSInteger sequenceId = strtol([[dataString substringWithRange:NSMakeRange(startIndex, 2)] UTF8String], 0, 16);
                startIndex += 2;
                
                NSString *timeStr = [dataString substringWithRange:NSMakeRange(startIndex, 8)];
                long long time = [self readTime:timeStr];
                startIndex += 4 * 2;
                
                NSInteger value = strtol([[dataString substringWithRange:NSMakeRange(startIndex, 2)] UTF8String], 0, 16);
                startIndex += 2;
                
                NSString *text = [NSString stringWithFormat:@"%@注射了%ld单位的胰岛素",[self getFullStringFromDate:time],value];
                [self logText:@"%@", text];
                [ret addObject:@{@"sequenceId":@(sequenceId), @"testTime":@(time), @"value":@(value)}];
                [sequenceIds addObject:@(sequenceId)];
            }
//            [self logText:@"数据：%@", ret];
            if (ret.count > 0) {
                [self deleteData:sequenceIds WithPeripheral:peripheral];
            }
        } else if (cmd == INSULINK_DATA_WAVE_CMD) {
            dataLen -= 2;   //减去校验位1个长度，命令位1个长度，得出波形数据实际长度
            NSString *waveString = [dataString substringWithRange:NSMakeRange(8, dataLen*2)];
            NSMutableString *logStr = [NSMutableString new];
            NSInteger dataCount = dataLen / 2;
            [self logText:@"波形组数长度:%ld", dataCount];
            NSInteger waveArr[dataCount];
            NSInteger i = 0;
            for (i = 0; i < dataCount-1; i++) {
                NSInteger value1 = strtol([[NSString stringWithFormat:@"%@%@", [waveString substringWithRange:NSMakeRange(i*4+2, 2)], [waveString substringWithRange:NSMakeRange(i*4, 2)]] UTF8String], 0, 16);
                waveArr[i] = value1;

                i++;
                NSInteger value2 = strtol([[NSString stringWithFormat:@"%@%@", [waveString substringWithRange:NSMakeRange(i*4+2, 2)], [waveString substringWithRange:NSMakeRange(i*4, 2)]] UTF8String], 0, 16);
                waveArr[i] = value2;

                [logStr appendFormat:@"%ld:%ld, %ld\n", i/2, value1, value2];
            }
            [self logText:@"波形数据：\n%@", logStr];
            if (dataCount > 0) {
                [self analyseWaveData:waveArr length:i/2];
            }
        } else if (cmd == INSULINK_DATA_WAVE_CMD_FINAL) {
//            [self logText:@"FINAL-波形数据:%@", dataString];
        } else {
            [self logText:@"不是传输数据命令"];
        }
        
    } else {
        [self logText:@"数据格式错误:%@", dataString];
    }
}

- (void)deleteData:(NSArray *)sequenceIds WithPeripheral:(CBPeripheral *)peripheral {
    NSInteger len = 1 + [sequenceIds count] + 1;
    NSString *ret = [NSString stringWithFormat:@"%@%@%@", INSULINK_DATA_PACKAGE_PREFIX, [self ToHex:len], [self ToHex:INSULINK_DATA_DELETE_CMD]];
    for (NSNumber *sequenceId in sequenceIds) {
        ret = [NSString stringWithFormat:@"%@%@", ret, [self ToHex:sequenceId.integerValue]];
    }
    
    NSInteger checksum = [self checkSum:[ret substringWithRange:NSMakeRange(4, ret.length-4)]];
    ret = [NSString stringWithFormat:@"%@%@", ret, [self ToHex:checksum]];
    NSData *data = [self hexToBytes:ret];
    [self logText:@"写入删除命令数据：%@", ret];
    NSMutableDictionary *info = self.peripheralDictionary[peripheral.identifier.UUIDString];
    [self writeCharacteristic:peripheral characteristic:info[characteristic_time_key] value:data];
}

- (void)logText:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    va_list paramList;
    va_start(paramList,format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:paramList];
    va_end(paramList);
    NSLog(@"%@", string);
    NSString *logStr = self.logView.text;
    [self.logView setText:[NSString stringWithFormat:@"%@\n->%@", logStr, string]];
    [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 1)];
}

- (void)analyseWaveData:(NSInteger *)s_arwMicData length:(NSInteger)g_nMicIntCnt {
    NSInteger const dataLength = g_nMicIntCnt;
//    for (NSInteger i = 0; i < g_nMicIntCnt; i++) {
//        [self logText:@"%ld, %ld", s_arwMicData[i * 2], s_arwMicData[i*2 + 1]];
//    }
    /****************常量区******************/
    NSInteger MIC_TAIL_CNT = (32768/3/2), s_wDebugInitCount = 0, s_wDebugFinalCount = 0;
#define MIC_HIGH_BEST      8//150
    /* Best duration for valid mic int high */
#define MIC_HIGH_MAX       200//1000
    /* Max duration for valid mic int low */
#define MIC_LOW_MAX       900//10000
    /* Max interval to sperate two times mic interrupt data */
#define MIC_INTERVAL_MAX  8192//32768
    /* Min interval to sperate two times mic interrupt data */
#define MIC_INTERVAL_MIN  20//38//150
    /* Min plus for low or high */
#define MIC_PLUS_MIN      6
    BOOL g_bMicDebugOverBLE = true;
    /***************************************/
    
    /* 过滤掉尾部无效时长数据 */
    NSInteger dwAveV = 0;
    NSInteger i, j, nStartIndex, nCount, nMaxIndex, nMinIndex, wDataDiff, nBestIndex = 0, nBestDiff = 0x0FFFF, nBestNum = 0;
    BOOL bDataChanged = false;
    for(i = g_nMicIntCnt-1; i>0; i--) {
        dwAveV += s_arwMicData[i*2] + s_arwMicData[i*2-1];
        if(dwAveV >= MIC_TAIL_CNT) {
            break;
        }
    }
    if(i == 0) {
        [self logText:@"No valid data,\r\n"];
        g_nMicIntCnt = 0;
        return;
    }
    
    s_arwMicData[i*2-1] = 0;
    g_nMicIntCnt = i;
    /* 过滤掉毛刺  持续时间小于最小持续时间的合并到前一组数据的间隔时间 */
    for(i=0; i<g_nMicIntCnt*2-1; i+=2) {
        if(s_arwMicData[i] < MIC_PLUS_MIN) {
            bDataChanged = TRUE;
            if(i > 0 && i < g_nMicIntCnt*2-2) {     //如果不是头一位和倒数第二位就把他和它后面一位加到前面
                s_arwMicData[i-1] += s_arwMicData[i] + s_arwMicData[i+1];
            }
            //数据往前挪
            memcpy(&s_arwMicData[i], &s_arwMicData[i+2], (g_nMicIntCnt * 2 - i - 2)*sizeof(typeof(s_arwMicData)));
            g_nMicIntCnt--;
            s_arwMicData[g_nMicIntCnt*2-1] = 0;
            s_arwMicData[g_nMicIntCnt*2-2] = 0;
            i-=2;
        }
    }
    if(bDataChanged) {
        [self logText:@"After filter min plus, Cnt=%ld\r\n", g_nMicIntCnt];
        bDataChanged = FALSE;
//        for (int k = 0; k < dataLength; k++) {
//            [self logText:@"%ld, %ld", s_arwMicData[k*2], s_arwMicData[k*2+1]];
//        }
    }
    
    /* 把持续时间超过最大门限的过滤掉 持续时间超过最大持续时间的去掉 */
    nStartIndex = 0;
    for(i=0; i<g_nMicIntCnt; i++) {
        if(s_arwMicData[i*2] > MIC_HIGH_MAX) {
            //            arch_printf("Filter high v(%d): v=%d, i=%d\r\n", i, s_arwMicData[i*2], s_arwMicData[i*2+1]);
            bDataChanged = TRUE;
            if(i > 0 && s_arwMicData[i*2-1] > 0) {
                if(s_arwMicData[i*2+1] == 0) {
                    s_arwMicData[i*2-1] = 0;
                } else {
                    s_arwMicData[i*2-1] += s_arwMicData[i*2] + s_arwMicData[i*2+1];
                }
            }
            for(j=i; j<g_nMicIntCnt-1; j++) {
                s_arwMicData[j*2] = s_arwMicData[j*2+2];
                s_arwMicData[j*2+1] = s_arwMicData[j*2+3];
            }
            if(j > 0) {
                s_arwMicData[j*2-1] = 0;
            }
            g_nMicIntCnt--;
            i--;
        }
    }
    if(bDataChanged) {
        [self logText:@"After filter high V, Cnt=%ld\r\n", g_nMicIntCnt];
        bDataChanged = FALSE;
    }
    
    /* 把间隔大于最大值的置为0，分段 */
    for(i=0; i<g_nMicIntCnt-1; i++) {
        if(s_arwMicData[i*2+1] > MIC_LOW_MAX) {
            bDataChanged = TRUE;
            s_arwMicData[i*2+1] = 0;
        }
    }
    if(bDataChanged) {
        [self logText:@"After filter high i, Cnt=%ld\r\n", g_nMicIntCnt];
        bDataChanged = FALSE;
    }
    
    /* 把间隔小于最小值的过滤掉，这是毛刺所以间隔时间很短 */
    for(i=g_nMicIntCnt-1; i>=0; i--) {
        if(s_arwMicData[i*2+1] > 0) {
            if(s_arwMicData[i*2+1] < MIC_INTERVAL_MIN) {
                //                arch_printf("Filter low min i(%d): v=%d, i=%d\r\n", i, s_arwMicData[i*2], s_arwMicData[i*2+1]);
                bDataChanged = TRUE;
                s_arwMicData[i*2] += s_arwMicData[i*2+1] + s_arwMicData[i*2+2];
                s_arwMicData[i*2+1] = s_arwMicData[i*2+3];
                j = i + 1;
                for(; j<g_nMicIntCnt-1; j++) {
                    s_arwMicData[j*2] = s_arwMicData[j*2+2];
                    s_arwMicData[j*2+1] = s_arwMicData[j*2+3];
                }
                if(j > 0) {
                    s_arwMicData[j*2-1] = 0;
                }
                g_nMicIntCnt--;
            }
        }
    }
    if(bDataChanged) {
        [self logText:@"After filter low min i, Cnt=%ld\r\n", g_nMicIntCnt];
        bDataChanged = FALSE;
    }
    
    /* 把间隔大于前后两个数最大值三倍的过滤掉 */
    for(i=0; i<g_nMicIntCnt; i++) {
        if(s_arwMicData[i*2+1] > 0) {
            /* 把间隔大于前后各两个数最大值三倍的过滤掉 */
            nMaxIndex = -1;
            if(i == 0 || s_arwMicData[i*2-1] == 0) {//当前数据段的第一个数，寻找它之后的连续两个的最大值
                if(s_arwMicData[i*2+3] > 0 && s_arwMicData[i*2+5] > 0) {
                    if(s_arwMicData[i*2+3] > s_arwMicData[i*2+5]) {
                        nMaxIndex = i + 1;
                    } else {
                        nMaxIndex = i + 2;
                    }
                }
            } else {
                nMaxIndex = i - 1;
            }
            
            if(nMaxIndex != -1 && s_arwMicData[i*2+1] > s_arwMicData[nMaxIndex*2+1] * 3 && s_arwMicData[i*2+1] > 10000){
                bDataChanged = TRUE;
                s_arwMicData[i*2+1] = 0;
                continue;
            }
        }
    }
    if(bDataChanged) {
        [self logText:@"After filter high i, Cnt=%ld\r\n", g_nMicIntCnt];
        bDataChanged = FALSE;
    }
    
    /* 把间隔小于前后两个数最小值一半的过滤掉 */
    /* 并且把连续两个间隔的和小于前后间隔最小值的过滤掉 */
    for(i=0; i<g_nMicIntCnt; i++) {
        if(s_arwMicData[i*2+1] > 0) {
            /* 把隔小于前后两个数最小值一半的过滤掉 */
            dwAveV = 0;
            if(i == 0 || s_arwMicData[i*2-1] == 0) {
                if(s_arwMicData[i*2+3] > 0 && s_arwMicData[i*2+5] > 0) {
                    if(s_arwMicData[i*2+3] < s_arwMicData[i*2+5])
                        dwAveV = s_arwMicData[i*2+3];
                    else
                        dwAveV = s_arwMicData[i*2+5];
                }
            } else if(s_arwMicData[i*2+3] > 0) {
                if(s_arwMicData[i*2-1] < s_arwMicData[i*2+3])
                    dwAveV = s_arwMicData[i*2-1];
                else
                    dwAveV = s_arwMicData[i*2+3];
            } else if(i > 1 && s_arwMicData[i*2-3] > 0) {
                if(s_arwMicData[i*2-1] < s_arwMicData[i*2-3])
                    dwAveV = s_arwMicData[i*2-1];
                else
                    dwAveV = s_arwMicData[i*2-3];
            }
            
            if(dwAveV > 0 && (s_arwMicData[i*2] + s_arwMicData[i*2+1] < dwAveV/2 || s_arwMicData[i*2+1] + s_arwMicData[i*2+2] < dwAveV/2)) {
                if(s_arwMicData[i*2] < s_arwMicData[i*2+2]) {
                    if(i > 0 && s_arwMicData[i*2-1] > 0) {
                        s_arwMicData[i*2-1] += s_arwMicData[i*2] + s_arwMicData[i*2+1];
                    }
                    j = i;
                } else {
                    if(s_arwMicData[i*2+3] == 0) {
                        s_arwMicData[i*2+1] = 0;
                    } else {
                        s_arwMicData[i*2+1] += s_arwMicData[i*2+2] + s_arwMicData[i*2+3];
                    }
                    j = i + 1;
                }
                for(; j<g_nMicIntCnt-1; j++) {
                    s_arwMicData[j*2] = s_arwMicData[j*2+2];
                    s_arwMicData[j*2+1] = s_arwMicData[j*2+3];
                }
                if(j > 0) {
                    s_arwMicData[j*2-1] = 0;
                }
                g_nMicIntCnt--;
                [self logText:@"Cnt=%ld\r\n", g_nMicIntCnt];
                if(i > 1) {
                    i -= 2;
                } else {
                    i = -1;
                }
                continue;
            }
        }
    }
    
    /* 计算最接近真实的数据段 */
    nStartIndex = 0;
    dwAveV = 0;
    nCount = 0;
    for(i=0; i<g_nMicIntCnt; i++) {
        //        arch_printf("Final(%02d): %d, %d,\r\n", i, s_arwMicData[i*2], s_arwMicData[i*2+1]);
        if(s_arwMicData[i*2] < MIC_HIGH_BEST)
            wDataDiff = MIC_HIGH_BEST - s_arwMicData[i*2];
        else
            wDataDiff = s_arwMicData[i*2] - MIC_HIGH_BEST;
        dwAveV += wDataDiff;
        nCount++;
        if(s_arwMicData[i*2+1] > 0) {
            continue;
        }
        /* 当前段有数据才处理 */
        if(dwAveV > 0) {
            nCount = i - nStartIndex + 1;
            dwAveV = dwAveV / nCount;
            [self logText:@"Ave diff=%ld, count=%ld\r\n", dwAveV, nCount];
            
            if(dwAveV < 100 && nBestDiff < 100) {
                if(nBestNum < nCount) {
                    nBestIndex = nStartIndex;
                    nBestDiff = dwAveV;
                    nBestNum = nCount;
                }
            }
            else if((int)dwAveV < nBestDiff) {
                nBestIndex = nStartIndex;
                nBestDiff = dwAveV;
                nBestNum = nCount;
            }
            [self logText:@"Best diff=%ld, best num=%ld, index=%ld\r\n", nBestDiff, nBestNum, nBestIndex];
        }
        
        dwAveV = 0;
        nStartIndex = i + 1;
        nCount = 0;
    }
    
    if(g_bMicDebugOverBLE && nBestIndex > 0) {
        for(i=0; i<nBestNum; i++) {
            s_arwMicData[i*2] = s_arwMicData[(nBestIndex+i)*2];
            s_arwMicData[i*2+1] = s_arwMicData[(nBestIndex+i)*2+1];
        }
    }
    
    g_nMicIntCnt = nBestNum;
    [self logText:@"===== Init count %ld, Final count %ld =====\r\n", s_wDebugInitCount, g_nMicIntCnt];
    
    if(!g_bMicDebugOverBLE && g_nMicIntCnt > 60) {
        g_nMicIntCnt = 60;
    }
    s_wDebugFinalCount = g_nMicIntCnt;
}

@end
