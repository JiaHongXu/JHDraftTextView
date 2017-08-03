//
//  JHDraftView.h
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHDraftParser.h"

@interface JHDraftTextView : UITextView

@property (nonatomic, strong) JHDraftParser *parser;

- (void)setAttributedTextWithDraftJsonDic:(NSDictionary *)jsonDic;

- (NSString *)wordAtPoint:(CGPoint)point;
- (NSString *)sentenceAtPoint:(CGPoint)point;

- (CGRect)rectForCharactersInRange:(NSRange)range;
- (CGRect)rectForWordAtPoint:(CGPoint)point;
@end
