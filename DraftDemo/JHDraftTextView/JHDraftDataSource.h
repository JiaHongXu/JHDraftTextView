//
//  JHDraftDataSource.h
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, JHDraftTextStyle) {
    JHDraftTextStyleNone            = 0,
    JHDraftTextStyleBold            = 1<<0,
    JHDraftTextStyleItalic          = 1<<1,
    JHDraftTextStyleStrikeThrough   = 1<<2,
};

typedef NS_ENUM(NSInteger, JHDraftTextType) {
    JHDraftTextTypeNone,
    JHDraftTextTypeH1,
    JHDraftTextTypeH2,
    JHDraftTextTypeH3,
    JHDraftTextTypeH4,
    JHDraftTextTypeH5,
    JHDraftTextTypeH6,
    JHDraftTextTypeOrderListItem,
    JHDraftTextTypeUnorderListItem,
    JHDraftTextTypeBlockQuote,
    JHDraftTextTypeCodeQuote,
    JHDraftTextTypeAtomic,
};

typedef NS_ENUM(NSInteger, JHDraftEntityType) {
    JHDraftEntityTypeNone,
    JHDraftEntityTypeLink,
};

@interface JHDraftEntityRange : NSObject
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger key;

+ (NSArray<JHDraftEntityRange *> *)entityRangesFromArray:(NSArray *)array;

@end

@interface JHDraftStyleRange: NSObject
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) JHDraftTextStyle style;

+ (NSArray<JHDraftStyleRange *> *)styleRangesFromArray:(NSArray *)array;
- (instancetype)initWithOffset:(NSInteger)offset length:(NSInteger)length textStyle:(JHDraftTextStyle)textStyle;
@end

@interface JHDraftBlock : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) JHDraftTextType type;
@property (nonatomic, strong) NSArray<JHDraftStyleRange *> *inlineStyleRanges;
@property (nonatomic, strong) NSArray<JHDraftEntityRange *> *entityRanges;
@property (nonatomic, strong) NSDictionary *data;

+ (NSArray<JHDraftBlock *> *)blocksFromDic:(NSDictionary *)dic;

@end

@interface JHDraftEntity : NSObject

@property (nonatomic, assign) JHDraftEntityType type;
@property (nonatomic, assign) BOOL mutable;
@property (nonatomic, strong) NSDictionary *data;

+ (NSDictionary *)entityMapWithDic:(NSDictionary *)dic;

@end


@interface JHDraftDataSource : NSObject

+ (NSArray<JHDraftBlock *> *)blocksFromJsonDic:(NSDictionary *)dic;

+ (NSDictionary<NSString *, JHDraftEntity *> *)entityMapFromJsonDic:(NSDictionary *)dic;

@end
