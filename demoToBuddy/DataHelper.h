#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
static NSInteger minlengthAccount = 4; // 惠信帐号最少位数
static NSInteger maxlengthAccout = 32; // 惠信帐号最多位数
static NSInteger minlengthPW = 8;      // 密码最少位数
static NSInteger maxlengthPW = 16;     // 密码最多位数

/// 自适应大小类型（宽高，或宽）
typedef enum
{
    /// 自适应宽
    AutoSizeHorizontal,
    /// 自适应宽高
    AutoSizeAll
}AutoSizeType;

@interface DataHelper : NSObject

/// 根据最小尺寸转换图片
+ (UIImage *)scaleImage:(UIImage *)image toMinSize:(float)size;

/// 根据比例转换图片
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/// 将图片转换成所需尺寸
+ (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size;

/// 保存图片到Cache
+ (void)saveImage:(UIImage *)tempImage WithPath:(NSString *)path;

/// 从文档目录下获取路径
+ (NSString *)cachesFolderPathWithName:(NSString *)imageName;

/// 指定路径删除文件
+ (void)removeCachesFolderAtPath:(NSString*)filePath;

/// 获取现在时间
+ (NSString *)getCurrentTime;

/// tableView隐藏多余的线
+ (void)setExtraCellLineHidden:(UITableView *)tableView;

/// 转化DeviceToken
+ (NSString *)conversionDeviceToken:(NSData *)deviceToken;

/// 获取一个随机整数，范围在[from,to），包括from，不包括to
+(int)getRandomNumber:(int)from to:(int)to;

/// 判断gps是否有效
+ (BOOL)gpsIsValidLongitude:(double)longitude latitude:(double)latitude;

/// 唯一字符串
+(NSString *)generateUUID;

/// 颜色设置
+ (UIColor *)colorWithHexString:(NSString *)color;

/// 32位 md5加密
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase;

/// 16位 md5加密
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase;

/// 获取文件MD5
+ (NSString *)fileMD5:(NSString *)path;

/// 计算高度
+ (CGFloat)heightWithString:(NSString *)string font:(UIFont *)font constrainedToWidth:(CGFloat)width;

/// 计算宽度
+ (CGFloat)widthWithString:(NSString *)string font:(UIFont *)font;

/// 当需要改变Label中的多段字体多个属性时调用 经改良后单个也可以
+ (NSMutableAttributedString *)getColorsInLabel:(NSString *)allStr colorStrs:(NSArray *)colorStrs colors:(NSArray *)colors fontSizes:(NSArray *)sizes;
 /// 获得绘制虚线方法
+ (UIView *)getLineWithSize:(CGSize)lineSize separateW:(CGFloat)separateW imaginaryW:(CGFloat)imaginaryW color:(UIColor *)color;

/// 设置textfiled左边的空白
+ (void)setEmptyLeftViewForTextField:(UITextField *)textField withFrame:(CGRect)rect;

/// 给谁谁发信息
+ (NSString *)showPromptMessage:(NSString *)phone;

/// 判断是否为空字符串
//+ (BOOL)isEmptyOrNull:(NSString *) string;

///  限制textfild 小数位数为2位
+ (BOOL)setRadixPointForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/// 金额输入限制位数，可自定义整数位
+ (BOOL)setlimitForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string number:(int)number;

/// 金额输入限制（首位不能为0）
+ (BOOL)setlimitForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string number:(int)number shouldBiggerThanOne:(BOOL)bigger;

/// 密码输入长度限制
+ (BOOL)setlimitPwdForTextField:(UITextField *)textField number:(int)number min:(BOOL)min;

/// string to number
+ (NSNumber *)stringToNum:(NSString *)string;

/// 加密手机号
+ (NSString *)getSecretStylePhone:(NSString *)phoneStr;

/// 替换frame 的高度
+ (CGRect)changeFrame:(CGRect)frame setHeight:(CGFloat)height;

/// 设置view的边框属性
+ (void)setlayerWithView:(UIView *)view radius:(CGFloat)radius borderColor:(UIColor *)bordercolor borderWidth:(CGFloat)borderwidth;

/// 设置自适应标签宽高
+ (void)setAutoSize:(UILabel *)label autoType:(AutoSizeType)type;

/// 获取当前app版本
+ (NSString *)getAppCurrentVersion;

/// 获取当前app包名
+ (NSString *)getBundleIdentifier;

/// 清除本地缓存文件
+ (void)clearCacheFile;

/// 计算本地缓存文件大小
+ (double)getCacheFileSize;

/// 把格式化的JSON格式的字符串转换成字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/// 图片拉伸
+ (UIImage *)resizableImage:(UIImage *)image;

/// 计算时间差（date计算后返回秒）
+ (int)getTimeInterval:(NSDate *)currentDate sinceDate:(NSDate *)sinceDate;

/// 是否是手机号码的字符串
+ (BOOL)isNumberString:(NSString *)string;

/// 网络请求是否异常（如404，500等）
+ (BOOL)webRequestStatus:(NSString *)infoStr;

///判断字符串是否为空
+(BOOL) isEmptyOrNull:(NSString *) string;
/**
 *  获取文件各项属性方法
 *
 *  @param fileName 文件流
 */
+ (NSData *)applicationDataFromFile:(NSString *)fileName;
///获取图片存储路径
+ (NSString *)getChatImagePathWithName:(NSString *)imageName;

/// 逗号分隔表示金额的字符串
+ (NSString *)spliteMoneyString:(NSString *)moneyStr;

/// 截取小数点后几位方法 moneyStr：金额字符串 nuberCount：保留小数点后几位不做四舍五入
/// 如剧情需要可设置基数加100即可 例：102表示保留2位小数 当值为0.00时自动转换为0
+ (NSString *)interceptMoneyString:(NSString *)moneyStr numberCount:(NSInteger)nuberCount;

///判断是否可以发送验证码（距上一次点击是否超过120秒
+ (BOOL)checkMsgIfCouldSendWithKey:(NSString *)key;

///获取星星
+ (NSString *)getStarStr:(NSUInteger)starNum;

/// 是否包含emoj表情
+ (BOOL)stringContainsEmoji:(NSString *)string;

/// 数组中相同的元素只保留一个
+ (NSArray *)arrayWithMemberIsOnly:(NSArray *)array;

@end
