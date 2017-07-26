//
//  JHDraftView.h
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHDraftTextView : UITextView

- (void)setAttributedTextWithDraftJsonDic:(NSDictionary *)jsonDic;

- (NSString *)wordAtPoint:(CGPoint)point;
- (NSString *)sentenceAtPoint:(CGPoint)point;
@end
