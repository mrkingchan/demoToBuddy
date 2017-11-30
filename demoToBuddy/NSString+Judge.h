//
//  NSString+Judge.h
//  GoodHappiness
//
//  Created by Chan on 3/25/16.
//  Copyright © 2016 Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Judge)

// 是否为有效的url
- (BOOL)isValidURL;
// 判断手机号
- (BOOL)isMobile;
// 邮编
- (BOOL)isPostcode;
// mail
- (BOOL)isMail;
// 空格
- (BOOL)isContainSpace;
// 电话
- (BOOL)isTel;
// Wejobss账号 必须以字母开头，可以使用6-20个字母、数字、下划线和减号，长度为最长20位，最少6位
- (BOOL)isHXAccount;
// 有效的昵称，只包含中文，英文，数字，下划线
- (BOOL)isLegalNickname;
//密码：6～12位数字、字母和特殊字符中至少两组组成
- (BOOL)isHxPassword;
+ (BOOL )isNull:(NSString *)string;
//去空格
+ (NSString *)stringBySpaceTrim:(NSString *)string;
+ (BOOL)isEmptyAfterSpaceTrim:(NSString *)string;
// 手机格式验证 长度11数字 (中国)
- (BOOL)isHxPhoneNumberCN;
// 手机格式验证 长度6-11数字（非中国）
- (BOOL)isHxPhoneNumber;
// 银卡号 8~25位数字
-(BOOL)isHxBankCardNumber;
// 提现金额非负数
-(BOOL)isHxMoney;
// 匹配身份证号码
-(BOOL)isHxIdentityCard;
// 特殊字符
//- (BOOL)isSpacialCharacter;
// 是否是合法的密码组成字符
- (BOOL)isLegalHXPasswordCharacter;
// 是否是合法的支付密码组成字符
- (BOOL)isLegalHXPayPasswordCharacter;
// 是否是合法的帐号组成字符
- (BOOL)isLegalHXAccountCharacter;
// 变更账户注册格式规则（数字+字母（大写自动转小写））
- (BOOL)isLegalHXAccountCharacterRegister;
// 合法身份证账号组成字符
- (BOOL)isLegalIDCardCharacter;
// 只输入数字 +字母 + _@.
- (BOOL)isLegalHKDemailCharacterRegister;
// 输入时根据条件限制 张绍裕 20140913
- (BOOL)isLegalCharacter:(NSString *)limitString;
//数字汉字字母下划线
- (BOOL)isLegalDigitCharacterChineseAndUnderline;

@end
