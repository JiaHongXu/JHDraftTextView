//
//  JHDraftDataSource.m
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHDraftDataSource.h"

#pragma mark - JHDraftEntityRange

@implementation JHDraftEntityRange

+ (NSArray<JHDraftEntityRange *> *)entityRangesFromArray:(NSArray *)array; {
    NSMutableArray<JHDraftEntityRange *> *ranges = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSDictionary *rangeDic in array) {
        [ranges addObject:[[JHDraftEntityRange alloc] initWithDic:rangeDic]];
    }
    
    return [ranges copy];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _offset = [[dic objectForKey:@"offset"] integerValue];
        _length = [[dic objectForKey:@"length"] integerValue];
        _key = [[dic objectForKey:@"key"] integerValue];
    }
    
    return self;
}

@end


#pragma mark - JHDraftStyleRange

@implementation JHDraftStyleRange

+ (NSArray<JHDraftStyleRange *> *)styleRangesFromArray:(NSArray *)array {
    NSMutableArray<JHDraftStyleRange *> *ranges = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSInteger capacity = 0;
    
    for (NSDictionary *rangeDic in array) {
        JHDraftStyleRange *range = [[JHDraftStyleRange alloc] initWithDic:rangeDic];
        [ranges addObject:range];
        if (capacity==0 || capacity<range.offset+range.length) {
            capacity = range.offset+range.length;
        }
    }
    
    // 对 styleRange 进行重排解析
    // 初始化 array 全部为 JHDraftTextStyleNone
    NSMutableArray *resortArray = [[NSMutableArray alloc] initWithCapacity:capacity];
    for (NSInteger index=0; index<capacity; index++) {
        resortArray[index] = @(JHDraftTextStyleNone);
    }
    for (JHDraftStyleRange *range in ranges) {
        for (NSInteger index=range.offset; index<range.length+range.offset; index++) {
            NSInteger value = [resortArray[index] integerValue];
            if (value==JHDraftTextStyleNone) {
                resortArray[index] = @(range.style);
            } else {
                resortArray[index] = @(range.style | value);
            }
        }
    }
    [ranges removeAllObjects];
    NSInteger index = 0;
    while (index<capacity) {
        NSInteger currentValue = [resortArray[index] integerValue];
        if (currentValue==JHDraftTextStyleNone) {
            index++;
            continue;
        }
        
        NSInteger offset = index;
        while (index+1<capacity && [resortArray[index+1] integerValue]==currentValue) {
            index++;
        }
        NSInteger length = index-offset+1;
        [ranges addObject:[[JHDraftStyleRange alloc] initWithOffset:offset length:length textStyle:currentValue]];
        index++;
    }
    return [ranges copy];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _offset = [[dic objectForKey:@"offset"] integerValue];
        _length = [[dic objectForKey:@"length"] integerValue];
        
        NSString *style = [dic objectForKey:@"style"];
        if ([style isEqualToString:@"BOLD"]) {
            _style = JHDraftTextStyleBold;
        } else if ([style isEqualToString:@"ITALIC"]) {
            _style = JHDraftTextStyleItalic;
        } else if ([style isEqualToString:@"STRIKETHROUGH"]) {
            _style = JHDraftTextStyleStrikeThrough;
        } else {
            _style = JHDraftTextStyleNone;
        }
    }
    
    return self;
}

- (instancetype)initWithOffset:(NSInteger)offset length:(NSInteger)length textStyle:(JHDraftTextStyle)textStyle {
    if (self = [super init]) {
        _offset = offset;
        _length = length;
        _style = textStyle;
    }
    
    return self;
}

@end


#pragma mark - JHDraftBlock

@implementation JHDraftBlock

+ (NSArray<JHDraftBlock *> *)blocksFromDic:(NSDictionary *)dic {
    NSMutableArray<JHDraftBlock *> *blocks = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSInteger order = 0;
    for (NSDictionary *blockDic in dic[@"blocks"]) {
        JHDraftBlock *block = [[JHDraftBlock alloc] initWithDic:blockDic];
        if (block.type == JHDraftTextTypeOrderListItem) {
            block.order = ++order;
        } else {
            order = 0;
        }
        [blocks addObject:block];
    }
    
    return [blocks copy];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _key = dic[@"key"];
        _text = dic[@"text"];
        _depth = [dic[@"depth"] integerValue];
        _inlineStyleRanges = [JHDraftStyleRange styleRangesFromArray:dic[@"inlineStyleRanges"]];
        _entityRanges = [JHDraftEntityRange entityRangesFromArray:dic[@"entityRanges"]];
        _type = [@{@"header-one":@(JHDraftTextTypeH1),
                   @"header-two":@(JHDraftTextTypeH2),
                   @"header-three":@(JHDraftTextTypeH3),
                   @"header-four":@(JHDraftTextTypeH4),
                   @"header-five":@(JHDraftTextTypeH5),
                   @"header-six":@(JHDraftTextTypeH6),
                   @"ordered-list-item":@(JHDraftTextTypeOrderListItem),
                   @"unordered-list-item":@(JHDraftTextTypeUnorderListItem),
                   @"blockquote":@(JHDraftTextTypeBlockQuote),
                   @"code-block":@(JHDraftTextTypeCodeQuote),
                   @"atomic":@(JHDraftTextTypeAtomic),
                   @"unstyled":@(JHDraftTextTypeNone),
                   }[dic[@"type"]] integerValue];
        _data = dic[@"data"];
    }
    
    return self;
}

@end


#pragma mark - JHDraftEntity

@implementation JHDraftEntity

+ (NSDictionary *)entityMapWithDic:(NSDictionary *)dic {
    NSMutableDictionary<NSString *, JHDraftEntity *> *entityMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (NSString *key in [dic[@"entityMap"] allKeys]) {
        [entityMap setObject:[[JHDraftEntity alloc] initWithDic:dic[@"entityMap"][key]] forKey:key];
    }
    
    return [entityMap copy];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        _mutable = [[dic objectForKey:@"mutability"] isEqualToString:@"MUTABLE"];
        _data = [dic objectForKey:@"data"];
        NSString *type = [dic objectForKey:@"type"];
        if ([type isEqualToString:@"LINK"]) {
            _type = JHDraftEntityTypeLink;
        }
    }
    
    return self;
}

@end


#pragma mark - JHDraftDataSource

@implementation JHDraftDataSource

+ (NSArray<JHDraftBlock *> *)blocksFromJsonDic:(NSDictionary *)jsonDic {
    return [JHDraftBlock blocksFromDic:jsonDic];
}

+ (NSDictionary<NSString *, JHDraftEntity *> *)entityMapFromJsonDic:(NSDictionary *)jsonDic {
    return [JHDraftEntity entityMapWithDic:jsonDic];
}

@end
