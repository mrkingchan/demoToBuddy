//
//  Model.h
//  demoToBuddy
//
//  Created by Chan on 2017/5/4.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property(nonatomic,copy)NSString *title;

@property(nonatomic,strong) NSArray *subTitles;

@property(nonatomic, assign) BOOL expand;

@end
