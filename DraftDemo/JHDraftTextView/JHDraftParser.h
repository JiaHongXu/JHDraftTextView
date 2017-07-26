//
//  JHDraftParser.h
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JHDraftParserDelegate <NSObject>

@optional
- (void)didUpdateAttributeText;

@end

@interface JHDraftParser : NSObject

@property (nonatomic, weak) id<JHDraftParserDelegate> delegate;

- (NSAttributedString *)attributeString;
- (NSAttributedString *)attributedStringWithDraftJsonDic:(NSDictionary *)jsonDic;

@end
