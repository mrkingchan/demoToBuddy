#import "DataHelper.h"
#import "SandboxFile.h"
#import "NSString+Judge.h"
#import "UIView+Frame.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach/mach_time.h>

#define FileHashDefaultChunkSizeForReadingData (1024 * 8)

@implementation DataHelper

+ (void)imageViewAnimation:(UIImageView *)imageView image:(UIImage *)image {
    imageView.alpha = 0;
    imageView.image = nil;
    [imageView setImage:image];
    
    NSTimeInterval animationDuration = 1.0f;
    [UIView beginAnimations:@"ImageLoaded" context:nil];
    [UIView setAnimationDuration:animationDuration];
    imageView.alpha = 1;
    [UIView commitAnimations];
}

//拉伸图片
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//拉伸图片
+ (UIImage *)scaleImage:(UIImage *)image toMinSize:(float)size {
    CGSize temSize = CGSizeZero;
    if (MIN(image.size.width, image.size.height) <= size) {
        temSize = image.size;
    } else if (image.size.width - image.size.height > 0) {
        temSize = CGSizeMake(image.size.width*size/image.size.height, size);
    } else {
        temSize = CGSizeMake(size, image.size.height * size / image.size.width);
    }
    UIGraphicsBeginImageContext(temSize);
    [image drawInRect:CGRectMake(0, 0, temSize.width, temSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

#pragma mark 保存图片到Cache

+ (void)saveImage:(UIImage *)tempImage WithPath:(NSString *)path {
    NSData *imageData = UIImageJPEGRepresentation(tempImage, 0.5);
//    NSString *fullPathToFile  = [self cachesFolderPathWithName:imageName];
    [imageData writeToFile:path atomically:NO];
//    return fullPathToFile;
}

#pragma mark 从文档目录下获取路径
+ (NSString *)cachesFolderPathWithName:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *fullPathToFile  = [cachesDirectory stringByAppendingPathComponent:imageName];
    return fullPathToFile;
//    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/%@",imageName]];
}

+ (void)removeCachesFolderAtPath:(NSString *)filePath {
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+ (NSString *)getCurrentTime {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowDate];
}

+ (void)setExtraCellLineHidden:(UITableView *)tableView {
    UIView *view =[[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+ (NSString *)conversionDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenStr = [[deviceTokenStr substringWithRange:NSMakeRange(0, 72)] substringWithRange:NSMakeRange(1, 71)];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return deviceTokenStr;
}

#pragma mark - gps

// 判断gps是否有效
+ (BOOL)gpsIsValidLongitude:(double)longitude latitude:(double)latitude {
    if (latitude != 0.0
        && longitude != 0.0
        && latitude < 90.0
        && latitude > -90.0
        && longitude < 180.0
        && longitude > -180.0) {
        return YES;
    }
    return NO;
}

#pragma mark - Random
// 获取一个随机整数，范围在[from,to），包括from，不包括to
+ (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to-from + 1)));
}

#pragma mark - xml

+ (NSString *)generateUUID {
    CFUUIDRef uuid;
    CFStringRef uuidString;
    NSString *result;
    uuid = CFUUIDCreate(NULL);
    uuidString = CFUUIDCreateString(NULL, uuid);
    result = [NSString stringWithFormat:@"%@",uuidString];
    CFRelease(uuidString);
    CFRelease(uuid);
    return result;
}

#pragma mark - UIColor

+ (UIColor *)colorWithHexString:(NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark - md5 32位加密

+ (NSString *)getMd5_32Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase {
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return uppercase ? [result uppercaseString] : result;
}

#pragma mark - md5 16位加密

+ (NSString *)getMd5_16Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase {
    // 提取32位MD5散列的中间16位
    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString uppercase:uppercase];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8]; // 即9～25位
    return result;
}

#pragma mark- 文件MD5

+ (NSString *)fileMD5:(NSString *)path {
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
                                      size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1)
            break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {

        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {

        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {

        CFRelease(fileURL);
    }
    return result;
}

#pragma mark - 计算高度
+ (CGFloat)heightWithString:(NSString *)string font:(UIFont *)font constrainedToWidth:(CGFloat)width {
    CGSize rtSize;
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        rtSize = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        return ceil(rtSize.height) + 0.5;
    } else {
        rtSize = [string sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return rtSize.height;
    }
}

#pragma mark- 单行文字宽度
+ (CGFloat)widthWithString:(NSString *)string font:(UIFont *)font {
    CGSize rtSize;
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        rtSize = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        return ceil(rtSize.width) + 0.5;
    } else {
        rtSize = [string sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return rtSize.width;
    }
}

#pragma mark - 当需要改变Label中的多段字体多个属性时调用 经改良后单个也可以
+ (NSMutableAttributedString *)getColorsInLabel:(NSString *)allStr colorStrs:(NSArray *)colorStrs colors:(NSArray *)colors fontSizes:(NSArray *)sizes {
    NSMutableAttributedString *allString = [[NSMutableAttributedString alloc]initWithString:allStr];
    // 若数组中有个数不一样时，则把颜色和大小都设置为第一个默认值
    if (colorStrs.count) {
        for (NSString *colorString in colorStrs) {
            NSRange stringRange = [allStr rangeOfString:colorString];
            NSMutableDictionary *stringDict = [NSMutableDictionary dictionary];
            NSInteger index = [colorStrs indexOfObject:colorString];
            UIColor *color;
            UIFont *font;
            if (colorStrs.count != colors.count || colorStrs.count != sizes.count) {
                color = colors.firstObject;
                font = [UIFont systemFontOfSize:[sizes.firstObject floatValue]];
            } else {
                color = colors[index];
                font = [UIFont systemFontOfSize:[sizes[index] floatValue]];
            }
            [stringDict setObject:color forKey:NSForegroundColorAttributeName];
            [stringDict setObject:font forKey:NSFontAttributeName];
            [allString setAttributes:stringDict range:stringRange];
        }
    }
    
    return allString;
}

/**
 ** 获得绘制虚线方法
 ** lineSize    线段的size
 ** separateW   实线线段的长度
 ** imaginaryW	间距
 ** color       虚线的颜色
 **/
+ (UIView *)getLineWithSize:(CGSize)lineSize separateW:(CGFloat)separateW imaginaryW:(CGFloat)imaginaryW color:(UIColor *)color
{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, lineSize.width, lineSize.height)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:color.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithFloat:separateW], [NSNumber numberWithFloat:imaginaryW], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
    return lineView;
}

/**
 ** lineView:	   需要绘制成虚线的view
 ** lineLength:	 虚线的宽度
 ** lineSpacing:	虚线的间距
 ** lineColor:	  虚线的颜色
 **/
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

#pragma mark- 设置TextField左边空白

+ (void)setEmptyLeftViewForTextField:(UITextField *)textField withFrame:(CGRect)rect {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    textField.leftView = view;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

/*
+ (HZActivityIndicatorView*)getActivityIndicatorView {
    HZActivityIndicatorView *activityIndicator = [[HZActivityIndicatorView alloc] init];
//    activityIndicator.backgroundColor = self.view.backgroundColor;
    activityIndicator.opaque = YES;
    activityIndicator.steps = 8;
    activityIndicator.finSize = CGSizeMake(2, 4);
    activityIndicator.indicatorRadius = 5;//指示器半径
    activityIndicator.stepDuration = 0.100;
    activityIndicator.color = [UIColor colorWithRed:0 green:174.0/255 blue:125.0/255 alpha:1.0];
    activityIndicator.roundedCoreners = UIRectCornerAllCorners;
    activityIndicator.cornerRadii = CGSizeMake(10, 10);//圆角半径
    return activityIndicator;
}
 */

+ (NSString *)showPromptMessage:(NSString *)phone {
    NSString *text;
    if ([phone isMobile]) {

        NSMutableString *phoneNumber = [NSMutableString stringWithString:phone];
        [phoneNumber replaceCharactersInRange:NSMakeRange(3,4) withString:@"****"];
        text = [NSString stringWithFormat:@"我们已经给您%@发送了验证短信",phoneNumber];
//        [iToast alertWithTitle:text];
    }
    return text;
}

/*
+(BOOL) isEmptyOrNull:(NSString *) string {
    if ([NSString isNull:string]) {
        // null object
        return YES;
    } else {
        NSString *trimedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return YES;
        } else {
            // is neither empty nor null
            return NO;
        }
    }
}
*/

/// 限制textfild 小数位数为2位
+ (BOOL)setRadixPointForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /*
    BOOL _isHasRadixPoint;
    if ([textField isFirstResponder]) {
        _isHasRadixPoint = YES;
        NSString *existText = textField.text;
        if ([existText rangeOfString:@"."].location == NSNotFound) {
            _isHasRadixPoint = NO;
        }
        if (string.length > 0) {
            unichar newChar = [string characterAtIndex:0];
            if ((newChar >= '0' && newChar <= '9') || newChar == '.' ) {
                if (newChar == '.') {
                    if (_isHasRadixPoint)
                        return NO;
                    else
                        return YES;
                }else {
                    if (_isHasRadixPoint) {
                        NSRange ran = [existText rangeOfString:@"."];
                        int radixPointCount = range.location - ran.location;
                        if (radixPointCount <= 2) return YES;
                        else return NO;
                    } else
                        return YES;
                }
                
            }else {
                if ( newChar == '\n') return YES;
                return NO;
            }
            
        }else {
            return YES;
        }
    }
    return YES;
     */
    if ([textField isFirstResponder]) {

     //   NSCharacterSet *firstSet = [NSCharacterSet characterSetWithCharactersInString:@".0"];
        NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *limitSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
        
        NSString *tempStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (tempStr.length == 1)
        {
            // 首个输入不能为0或小数点
        //    NSRange firstRange = [tempStr rangeOfCharacterFromSet:firstSet];
            // 但可以输入数字
            NSRange numberRange = [tempStr rangeOfCharacterFromSet:numberSet];
            if (/*IfirstRange.location != NSNotFound || */numberRange.location == NSNotFound)
            {
                return NO;
            }
        }
        else if (tempStr.length > 1)
        {
            /*
            // 编辑状态中移动光标后，首个输入不能为0
            NSString *firstString = [tempStr substringToIndex:1];
            if ([firstString isEqualToString:@"0"] || [firstString isEqualToString:@"."])
            {
                return NO;
            }
            */
            for (int i = 0; i < tempStr.length; i++)
            {
                NSString *subString = [tempStr substringWithRange:NSMakeRange(i, 1)];
                
                // 只能输入数字和小数点
                NSRange numberRange = [subString rangeOfCharacterFromSet:limitSet];
                if (numberRange.location == NSNotFound)
                {
                    return NO;
                }
            }
            
            // 无小数点时，只能输入6个数字
            NSRange pointRange = [tempStr rangeOfString:@"."];
            if (pointRange.location == NSNotFound && 7 == tempStr.length)
            {
                return NO;
            }
            
            // 存在小数点时，只能再输入两位小数，不能再输入小数点
            if (pointRange.location != NSNotFound)
            {
                // 只能有一个小数点
                CGFloat limitlength = pointRange.location + pointRange.length;
                NSString *temp = [tempStr substringFromIndex:limitlength];
                NSRange hasPointRange = [temp rangeOfString:@"."];
                if (hasPointRange.location != NSNotFound)
                {
                    return NO;
                }
                
                // 小数点后两位
                if (limitlength + 3 == tempStr.length)
                {
                    return NO;
                }
                
                // 存在小数时点，整数不足五位时，最多只能输入6位
                NSString *subTemp = [tempStr substringToIndex:pointRange.location];
                if (7 == subTemp.length)
                {
                    return NO;
                }
            }
        }
        return YES;
        
    }
    return YES;
}

// 金额输入限制位数，可自定义整数位
+ (BOOL)setlimitForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string number:(int)number {
    if ([textField isFirstResponder]) {

        NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *limitSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
        
        NSString *tempStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (tempStr.length == 1)
        {
            // 首个输入不能为小数点
            // 但可以输入数字
            NSRange numberRange = [tempStr rangeOfCharacterFromSet:numberSet];
            if (numberRange.location == NSNotFound)
            {
                return NO;
            }
        }
        else if (tempStr.length > 1)
        {
            for (int i = 0; i < tempStr.length; i++)
            {
                NSString *subString = [tempStr substringWithRange:NSMakeRange(i, 1)];
                
                // 只能输入数字和小数点
                NSRange numberRange = [subString rangeOfCharacterFromSet:limitSet];
                if (numberRange.location == NSNotFound)
                {
                    return NO;
                }
            }
            
            // 无小数点时，只能输入number个数字，0时无限制
            NSRange pointRange = [tempStr rangeOfString:@"."];
            if (number != 0)
            {
                if (pointRange.location == NSNotFound && number + 1 == tempStr.length)
                {
                    return NO;
                }
            }
            
            // 存在小数点时，只能再输入两位小数，不能再输入小数点
            if (pointRange.location != NSNotFound)
            {
                // 只能有一个小数点
                CGFloat limitlength = pointRange.location + pointRange.length;
                NSString *temp = [tempStr substringFromIndex:limitlength];
                NSRange hasPointRange = [temp rangeOfString:@"."];
                if (hasPointRange.location != NSNotFound)
                {
                    return NO;
                }
                
                // 小数点后两位
                if (limitlength + 3 == tempStr.length)
                {
                    return NO;
                }
                
                // 存在小数时点，整数不足五位时，最多只能输入6位，0时无限制
                if (number != 0)
                {
                    NSString *subTemp = [tempStr substringToIndex:pointRange.location];
                    if (number + 1 == subTemp.length)
                    {
                        return NO;
                    }
                }
            }
        }
        
        return YES;
    }
    return YES;
}

// 金额输入限制（首位不能为0）
+ (BOOL)setlimitForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string number:(int)number shouldBiggerThanOne:(BOOL)bigger {
    if ([textField isFirstResponder]) {

        NSCharacterSet *withoutZeroNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"123456789"];
        NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *limitSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
        
        NSString *tempStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (tempStr.length == 1)
        {
            // 首个输入限制
            if (bigger)
            {
                // 不能为0或小数点，即不能小于1
                NSRange numberRange = [tempStr rangeOfCharacterFromSet:withoutZeroNumberSet];
                if (numberRange.location == NSNotFound)
                {
                    return NO;
                }
            }
            else
            {
                // 可以小于1
                NSRange numberRange = [tempStr rangeOfCharacterFromSet:numberSet];
                if (numberRange.location == NSNotFound)
                {
                    return NO;
                }
            }
        }
        else if (tempStr.length > 1)
        {
            // 如果允许首个数字为0，则第二个数字非0时，或非小数点时，首位自动更新为非0数字 张绍裕 20150722
            NSString *firstString = [tempStr substringWithRange:NSMakeRange(0, 1)];
            NSString *secondString = [tempStr substringWithRange:NSMakeRange(1, 1)];
            if (!bigger && [firstString isEqualToString:@"0"] && ![secondString isEqualToString:@"."])
            {
                textField.text = secondString;
            }
            
            for (int i = 0; i < tempStr.length; i++)
            {
                NSString *subString = [tempStr substringWithRange:NSMakeRange(i, 1)];
                
                // 只能输入数字和小数点
                NSRange numberRange = [subString rangeOfCharacterFromSet:limitSet];
                if (numberRange.location == NSNotFound)
                {
                    return NO;
                }
            }
            
            // 无小数点时，只能输入number个数字，0时无限制; 如果第一个数字为0，也不让输入
            NSRange pointRange = [tempStr rangeOfString:@"."];
            if (number != 0)
            {
                if (pointRange.location == NSNotFound && number + 1 == tempStr.length)
                {
                    return NO;
                }
                
                if (pointRange.location == NSNotFound && [[tempStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"]) {
                    return NO;
                }
            }
            
            // 存在小数点时，只能再输入两位小数，不能再输入小数点
            if (pointRange.location != NSNotFound)
            {
                // 只能有一个小数点
                CGFloat limitlength = pointRange.location + pointRange.length;
                NSString *temp = [tempStr substringFromIndex:limitlength];
                NSRange hasPointRange = [temp rangeOfString:@"."];
                if (hasPointRange.location != NSNotFound)
                {
                    return NO;
                }
                
                // 小数点后两位
                if (limitlength + 3 == tempStr.length)
                {
                    return NO;
                }
                
                // 存在小数时点，整数不足五位时，最多只能输入6位，0时无限制
                if (number != 0)
                {
                    NSString *subTemp = [tempStr substringToIndex:pointRange.location];
                    if (number + 1 == subTemp.length)
                    {
                        return NO;
                    }
                }
            }
        }
        
        return YES;
    }
    return YES;
}

// 密码输入长度限制
+ (BOOL)setlimitPwdForTextField:(UITextField *)textField number:(int)number min:(BOOL)min {
    // 密码限制，输入8-16位
    if ([textField isFirstResponder] && ![NSString isNull:textField.text]) {

        if (!min)
        {
            // 密码限制最多输入16位
            if (textField.text.length > number - 1)
            {
                return NO;
            }
        }
        else
        {
            // 最少输入8位
            if (textField.text.length < number)
            {
//                [iToast alertWithTitle:@"请输入8到16位密码"];
                return NO;
            }
        }
    }
    
    return YES;
}

// string to number
+ (NSNumber *)stringToNum:(NSString *)string {
    return [NSNumber numberWithLongLong:[string longLongValue]];
}

+ (NSString *)getSecretStylePhone:(NSString *)phoneStr {
    return [phoneStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}

// 替换frame 的高度
+ (CGRect)changeFrame:(CGRect)frame setHeight:(CGFloat)height {
    CGRect newFrame = frame;
    newFrame.size.height = height;
    return newFrame;
}

// 设置view的边框属性
+ (void)setlayerWithView:(UIView *)view radius:(CGFloat)radius borderColor:(UIColor *)bordercolor borderWidth:(CGFloat)borderwidth {
    if (view) {

        if (radius > 0.0)
        {
            view.layer.cornerRadius = radius;
            view.layer.masksToBounds = YES;
        }
        
        if (bordercolor && borderwidth > 0.0)
        {
            view.layer.borderColor = bordercolor.CGColor;
            view.layer.borderWidth = borderwidth;
        }
    }
}

// 设置自适应标签宽高
+ (void)setAutoSize:(UILabel *)label autoType:(AutoSizeType)autotype {
    if (label) {

        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        CGSize size = CGSizeMake(label.size.width, 9999.9);
        CGSize labelsize = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:label.lineBreakMode];
        if (AutoSizeHorizontal == autotype)
        {
            label.frame = CGRectMake(label.origin.x, label.origin.y, labelsize.width, label.height);
        }
        else if (AutoSizeAll == autotype)
        {
            label.frame = CGRectMake(label.origin.x, label.origin.y, labelsize.width, labelsize.height);
        }
    }
}

// 获取当前app版本
+ (NSString *)getAppCurrentVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *versionString = [NSString stringWithFormat:@"%@", appCurVersion];
    return versionString;
}

/// 获取当前app包名
+ (NSString *)getBundleIdentifier {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleIdentifier"];
}

// 清除本地缓存文件
+ (void)clearCacheFile {
    //缓存文件
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //缓存文件夹下的子路径
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    for (NSString *fileName in files) {
        NSError *error;
        NSString *path = [cachPath stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //移除文件路径,清除缓存文件夹下的文件
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

// 计算本地缓存文件大小
+ (double)getCacheFileSize {
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    double fileSize = 0.0;
    //拿到缓存路径
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //拿到缓存下的子文件夹
    NSArray *files = [fileManager subpathsAtPath:cachPath];
    for (NSString *fileName in files) {
        NSString *path = [cachPath stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:path]) {
            //统计缓存大小
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
            //累加缓存文件大小
            fileSize += (double)([fileAttributes fileSize]);
        }
    }
    
    return fileSize;
}


/**
 *  把格式化的JSON格式的字符串转换成字典
 *  @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

// 图片拉伸
+ (UIImage *)resizableImage:(UIImage *)image {
    if (image) {

        return [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    }
    
    return nil;
}

// 计算时间差（date计算后返回秒）
+ (int)getTimeInterval:(NSDate *)currentDate sinceDate:(NSDate *)sinceDate {
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:sinceDate];
    
    return (int)timeInterval;
}

// 是否是手机号码的字符串
+ (BOOL)isNumberString:(NSString *)string {
    NSString *regex = @"^(13[0-9]|14[0-9]|15[0-9]|18[0-9])\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:string];
    if (isMatch) {

        return YES;
    } else {
        return NO;
    }
}

//判断字符串是否为空
+(BOOL) isEmptyOrNull:(NSString *) string {
    if ([NSString isNull:string]) {
        // null object
        return YES;
    } else {
        NSString *trimedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return YES;
        } else {
            // is neither empty nor null
            return NO;
        }
    }
}

// 网络请求是否异常（如404，500等）
+ (BOOL)webRequestStatus:(NSString *)infoStr {
    if ([NSString isNull:infoStr]) {

        return NO;
    }
    
    BOOL resutl = YES;
    NSArray *array = [self getRequestErrors];
    for (NSString *error in array) {

        NSRange range = [infoStr rangeOfString:error];
        if (range.location != NSNotFound)
        {
            resutl = NO;
            break;
        }
    }
    
    return resutl;
}

+ (NSArray *)getRequestErrors {
    NSMutableArray *errorsArray = [NSMutableArray array];
    [errorsArray addObject:@"400错误"]; // 错误请求，如语法错误
    [errorsArray addObject:@"401错误"]; // 请求授权失败
    [errorsArray addObject:@"402错误"]; // 保留有效ChargeTo头响应
    [errorsArray addObject:@"403错误"]; // 请求不允许
    [errorsArray addObject:@"404错误"]; // 没有发现文件、查询或URl
    [errorsArray addObject:@"405错误"]; // 用户在Request-Line字段定义的方法不允许
    [errorsArray addObject:@"406错误"]; // 根据用户发送的Accept拖，请求资源不可访问
    [errorsArray addObject:@"407错误"]; // 类似401，用户必须首先在代理服务器上得到授权
    [errorsArray addObject:@"408错误"]; // 客户端没有在用户指定的饿时间内完成请求
    [errorsArray addObject:@"409错误"]; // 对当前资源状态，请求不能完成
    [errorsArray addObject:@"410错误"]; // 服务器上不再有此资源且无进一步的参考地址
    [errorsArray addObject:@"411错误"]; // 服务器拒绝用户定义的Content-Length属性请求
    [errorsArray addObject:@"412错误"]; // 一个或多个请求头字段在当前请求中错误
    [errorsArray addObject:@"413错误"]; // 请求的资源大于服务器允许的大小
    [errorsArray addObject:@"414错误"]; // 请求的资源URL长于服务器允许的长度
    [errorsArray addObject:@"415错误"]; // 请求资源不支持请求项目格式
    [errorsArray addObject:@"416错误"]; // 请求中包含Range请求头字段，在当前请求资源范围内没有range指示值，请求也不包含If-Range请求头字段
    [errorsArray addObject:@"417错误"]; // 服务器不满足请求Expect头字段指定的期望值，如果是代理服务器，可能是下一级服务器不能满足请求
    [errorsArray addObject:@"500错误"]; // 服务器产生内部错误
    [errorsArray addObject:@"501错误"]; // 服务器不支持请求的函数
    [errorsArray addObject:@"502错误"]; // 服务器暂时不可用，有时是为了防止发生系统过载
    [errorsArray addObject:@"503错误"]; // 服务器过载或暂停维修
    [errorsArray addObject:@"504错误"]; // 关口过载，服务器使用另一个关口或服务来响应用户，等待时间设定值较长
    [errorsArray addObject:@"505错误"]; // 服务器不支持或拒绝支请求头中指定的HTTP版本
    
    return errorsArray;
}

/**
 *  获取文件各项属性方法
 *
 *  @param fileName 文件流
 */
+ (NSData *)applicationDataFromFile:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory =[paths objectAtIndex:0];
	NSString *appFile =[documentsDirectory stringByAppendingPathComponent:fileName];
	NSData *data =[[NSData alloc]initWithContentsOfFile:appFile];
	return data;
}

///获取图片存储路径
+ (NSString *)getChatImagePathWithName:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@""];
    
    if (![SandboxFile IsFileExists:cachesDirectory]) {
        [SandboxFile CreateList:[paths objectAtIndex:0] ListName:@""];
    }
    
    NSString *fullPathToFile  = [cachesDirectory stringByAppendingPathComponent:imageName];
    return fullPathToFile;
}

/// 逗号分隔表示金额的字符串
+ (NSString *)spliteMoneyString:(NSString *)moneyStr {
    if ([NSString isEmptyAfterSpaceTrim:moneyStr]) {
        return nil;
    }
    
    NSMutableString *mStr = [[NSMutableString alloc] init];
    NSArray *floatSpArr = [moneyStr componentsSeparatedByString:@"."];
    // 浮点部分
    NSString *floatPart = [floatSpArr count] > 1 ? floatSpArr[1]: nil;
    NSString *integerPart = floatSpArr[0];
    int integerPartLen = integerPart.length;
    
    //
    int u3len = integerPartLen / 3;
    int umLen = integerPartLen % 3;
    
    // 组合满3位的
    for (int i = 0; i < u3len; i++) {
        NSString *tempStr;
        tempStr = [integerPart substringWithRange:NSMakeRange(integerPartLen - (i+1)*3, 3)];
        [mStr insertString:(i==0)?tempStr:[NSString stringWithFormat:@"%@,", tempStr] atIndex:0];
    }
    
    // 组合不满三位的
    if (umLen > 0) {
        NSString *tempStr;
        tempStr = [integerPart substringWithRange:NSMakeRange(0, umLen)];
        if (mStr.length <= 0) {
            [mStr insertString:[NSString stringWithFormat:@"%@", tempStr] atIndex:0];
        } else  {
            [mStr insertString:[NSString stringWithFormat:@"%@,", tempStr] atIndex:0];
        }
    }

    // 拼接浮点部分
    if (floatPart) {
        [mStr appendFormat:@".%@", floatPart];
    }
    
    return mStr;
}

/// 截取小数点后几位方法 moneyStr：金额字符串 nuberCount：保留小数点后几位不做四舍五入
/// 如剧情需要可设置基数加100即可 例：102表示保留2位小数 当值为0.00时自动转换为0
+ (NSString *)interceptMoneyString:(NSString *)moneyStr numberCount:(NSInteger)nuberCount {
    
    NSArray *floatSpArr = [moneyStr componentsSeparatedByString:@"."];
    // 浮点部分
    NSString *floatPart = [floatSpArr count] > 1 ? floatSpArr[1]: @"0";
    NSString *integerPart = floatSpArr[0];
    BOOL isNeedZero = NO;//是否将0.00转换为0
    if (nuberCount > 100) {
        nuberCount = nuberCount - 100;
        isNeedZero = YES;
    }
    if (floatPart.length > nuberCount) {
        floatPart = [floatPart substringToIndex:nuberCount];
    } else if (floatPart.length < nuberCount) {
        NSMutableString *addStr = [[NSMutableString alloc]initWithCapacity:0];
        for (int i = 0; i < nuberCount - floatPart.length; i++) {
            [addStr appendString:@"0"];
        }
        floatPart = [NSString stringWithFormat:@"%@%@", floatPart, addStr];
    }
    if(nuberCount > 0) {
        moneyStr = [NSString stringWithFormat:@"%@.%@", integerPart, floatPart];
    } else {
        moneyStr = [NSString stringWithFormat:@"%@", integerPart];
    }
    
    if ([integerPart isEqualToString:@"0"] && isNeedZero) {//需要0.00转化为0时，判断数值是否为0
        NSMutableString *addStr = [[NSMutableString alloc]initWithCapacity:0];
        for (int i = 0; i < floatPart.length; i++) {
            [addStr appendString:@"0"];
        }
        if ([floatPart isEqualToString:addStr]) {
            moneyStr = @"0";
        }
    }
    return moneyStr;
}


+ (BOOL)checkMsgIfCouldSendWithKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger lastClickTime = [userDefaults doubleForKey:key];
    
    NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"currentTime - lastClickTime = %@", @(currentTime - lastClickTime));
    if (currentTime - lastClickTime < 120) {
//        [iToast alertWithTitle:@"请求频繁,请稍后再试"];
        return NO;
    }
    [userDefaults setInteger:currentTime forKey:key];
    [userDefaults synchronize];
    return YES;
}

+ (NSString *)getStarStr:(NSUInteger)starNum {
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i = 0 ; i < starNum; i++) {
        [str appendString:@"*"];
    }
    
    return str;
}


+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff)
                                {
                                    if (substring.length > 1)
                                    {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f)
                                        {
                                            returnValue = YES;
                                        }
                                    }
                                }
                                else if (substring.length > 1)
                                {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3)
                                    {
                                        returnValue = YES;
                                    }
                                }
                                else
                                {
                                    if (0x2100 <= hs && hs <= 0x27ff)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (0x2B05 <= hs && hs <= 0x2b07)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (0x2934 <= hs && hs <= 0x2935)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (0x3297 <= hs && hs <= 0x3299)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
                                    {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

/// 数组中相同元素只取其中一个
+ (NSArray *)arrayWithMemberIsOnly:(NSArray *)array {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [array count]; i++) {
        @autoreleasepool {
            if ([categoryArray containsObject:[array objectAtIndex:i]] == NO) {
                [categoryArray addObject:[array objectAtIndex:i]];
            }
        }
    }
    return categoryArray;
}


@end
