//
//  JHDraftParser.h
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JHDraftDataSource.h"

@protocol JHDraftParserDelegate <NSObject>

@required
- (void)didUpdateAttributeText;

@end

@interface JHParserDrawTask : NSObject

@property (nonatomic, assign) JHDraftTextType type;
@property (nonatomic, assign) NSUInteger fisrtIndex;
@property (nonatomic, assign) NSUInteger lastIndex;

@end

@interface JHDraftParser : NSObject

// <@(JHDraftTextType), NSParagraphStyle*>
@property (nonatomic, strong) NSDictionary<NSNumber *, NSParagraphStyle *> *paragraphStyles;

// <@(JHDraftTextStyle), NSString *>
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *fonts;

// <@(JHDraftTextType), @(CGFloat)>
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *fontSizes;

@property (nonatomic, weak) id<JHDraftParserDelegate> delegate;

- (NSAttributedString *)attributeString;
- (NSAttributedString *)attributedStringWithDraftJsonDic:(NSDictionary *)jsonDic;
- (NSArray<JHParserDrawTask *> *)parserDrawTasks;

@end
