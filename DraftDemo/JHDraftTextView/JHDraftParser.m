//
//  JHDraftParser.m
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHDraftParser.h"

#import <SDWebImage/SDWebImageManager.h>

@interface JHDraftParser ()
@property (nonatomic, strong) NSMutableAttributedString *mutableAttrStr;
@property (nonatomic, strong) NSMutableArray<JHParserDrawTask *> *drawTasks;

// <@(JHDraftTextType), NSParagraphStyle*>
@property (nonatomic, strong) NSDictionary<NSNumber *, NSParagraphStyle *> *paragraphStyles;
// <@(JHDraftTextType), NSString *>
@property (nonatomic, strong) NSDictionary<NSNumber *,NSString *> *fonts;
// <@(JHDraftTextType), @(CGFloat)>
@property (nonatomic, strong) NSDictionary<NSNumber *,NSNumber *> *fontSizes;
@end

@implementation JHDraftParser

#pragma mark - Public Methods

- (NSAttributedString *)attributedStringWithDraftJsonDic:(NSDictionary *)jsonDic {
    NSDictionary<NSString *, JHDraftEntity *> *entityMap = [JHDraftDataSource entityMapFromJsonDic:jsonDic];
    NSArray<JHDraftBlock *> *blocks = [JHDraftDataSource blocksFromJsonDic:jsonDic];
    
    return [self _attributeStringWithBlocks:blocks entityMap:entityMap];
}

- (NSArray<JHParserDrawTask *> *)parserDrawTasks {
    return [self.drawTasks copy];
}

#pragma mark - Private Methods

- (NSAttributedString *)_attributeStringWithBlocks:(NSArray<JHDraftBlock *> *)blocks entityMap:(NSDictionary<NSString *, JHDraftEntity *> *)entityMap {
    
    _mutableAttrStr = [[NSMutableAttributedString alloc] init];
    
    for (JHDraftBlock *block in blocks) {
        NSAttributedString *attrStr = [self _attributeStringWithBlock:block entityMap:entityMap];
        if (_mutableAttrStr.length!=0) {
            [_mutableAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        [_mutableAttrStr appendAttributedString:attrStr];
    }
    
    return [_mutableAttrStr copy];
}

- (NSAttributedString *)_attributeStringWithBlock:(JHDraftBlock *)block entityMap:(NSDictionary<NSString *, JHDraftEntity *> *)entityMap {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:block.text];
    
    CGFloat fontSize = [self.fontSizes[@(block.type)] doubleValue];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.fonts[@(JHDraftTextStyleNone)] size:fontSize] range:NSMakeRange(0, block.text.length)];
    
    // 配置局部字体样式
    for (JHDraftStyleRange *styleRange in block.inlineStyleRanges) {
        
        NSRange range = NSMakeRange(styleRange.offset, styleRange.length);
        if ((styleRange.style & JHDraftTextStyleBold) && (styleRange.style & JHDraftTextStyleItalic)) {
            // 又斜又粗
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.fonts[@(JHDraftTextStyleBold&JHDraftTextStyleItalic)] size:fontSize] range:range];
        } else if (styleRange.style & JHDraftTextStyleBold) {
            // 粗体
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.fonts[@(JHDraftTextStyleBold)] size:fontSize] range:range];
        } else if (styleRange.style & JHDraftTextStyleItalic) {
            // 斜体
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.fonts[@(JHDraftTextStyleItalic)] size:fontSize] range:range];
        }
        
        if (styleRange.style & JHDraftTextStyleStrikeThrough) {
            [attrStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
        }
    }
    
    // 配置超链接
    for (JHDraftEntityRange *entityRange in block.entityRanges) {
        NSRange range = NSMakeRange(entityRange.offset, entityRange.length);
        JHDraftEntity *entity = entityMap[[NSString stringWithFormat:@"%ld", entityRange.key]];
        if (entity.type == JHDraftEntityTypeLink) {
            [attrStr addAttribute:NSLinkAttributeName value:entity.data[@"url"] range:range];
        }
    }
    
    // 配置整体段落样式
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    switch (block.type) {
        case JHDraftTextTypeH1:
        case JHDraftTextTypeH2:
        case JHDraftTextTypeH3:
        case JHDraftTextTypeH4:
        case JHDraftTextTypeH5:
        case JHDraftTextTypeH6:
        {
            paragraph = [self.paragraphStyles[@(block.type)] mutableCopy];
        }
            break;
        case JHDraftTextTypeBlockQuote:
        {
            paragraph = [self.paragraphStyles[@(block.type)] mutableCopy];
            
            JHParserDrawTask *drawTask = [[JHParserDrawTask alloc] init];
            drawTask.type = JHDraftTextTypeBlockQuote;
            drawTask.fisrtIndex = _mutableAttrStr.length+1;
            drawTask.lastIndex = drawTask.fisrtIndex + attrStr.length - 1;
            [self.drawTasks addObject:drawTask];
        }
            break;
        case JHDraftTextTypeCodeQuote:
        {
            paragraph = [self.paragraphStyles[@(block.type)] mutableCopy];
            
            JHParserDrawTask *drawTask = [[JHParserDrawTask alloc] init];
            drawTask.type = JHDraftTextTypeCodeQuote;
            drawTask.fisrtIndex = _mutableAttrStr.length+1;
            drawTask.lastIndex = drawTask.fisrtIndex + attrStr.length - 1;
            [self.drawTasks addObject:drawTask];
        }
            break;
        case JHDraftTextTypeOrderListItem:
        case JHDraftTextTypeUnorderListItem:
        {
            CGFloat headIndent = 32*(1+block.depth);
            paragraph = [self.paragraphStyles[@(block.type)] mutableCopy];
            
            NSAttributedString *prefixStr = nil;
            CGSize size;
            if (block.type == JHDraftTextTypeOrderListItem) {
                prefixStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld. ", block.order]
                                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:self.fonts[@(JHDraftTextStyleNone)] size:fontSize]}];
            } else {
                prefixStr = [[NSAttributedString alloc] initWithString:@"• "
                                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:self.fonts[@(JHDraftTextStyleNone)] size:fontSize]}];
            }
            UILabel *prefixLabel = [[UILabel alloc] init];
            prefixLabel.attributedText = prefixStr;
            NSRange range = NSMakeRange(0, prefixStr.length);
            size = [prefixStr.string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[prefixStr attributesAtIndex:0 effectiveRange:&range] context:nil].size;
            [attrStr insertAttributedString:prefixStr atIndex:0];
            paragraph.firstLineHeadIndent = headIndent-size.width;
            paragraph.headIndent = headIndent;
        }
            break;
        case JHDraftTextTypeAtomic:
        {
            __block NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            __weak __typeof__(self) weakSelf = self;
            if ([block.data[@"type"] isEqualToString:@"image"]) {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager loadImageWithURL:[NSURL URLWithString:block.data[@"url"]]
                                  options:0
                                 progress:nil
                                completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                    attachment.image = image;
                                    if (weakSelf.delegate) {
                                        [weakSelf.delegate didUpdateAttributeText];
                                    }
                                }];
                attachment.bounds = CGRectMake(0, 0, 300, 200);
                NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
                [attrStr appendAttributedString:attachmentStr];
            }
            break;
        }
        case JHDraftTextTypeNone:
        default:
        {
            paragraph = [self.paragraphStyles[@(block.type)] mutableCopy];
        }
            break;
    }
    
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:paragraph
                    range:NSMakeRange(0, attrStr.length)];
    
    
    
    return attrStr;
}

- (UIImage*)_imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f ,1.0f ,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

#pragma mark - Getter

- (NSDictionary *)attributesWithDescriptor: (UIFontDescriptor*)descriptor size:(CGFloat)size {
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:size];
    return @{NSFontAttributeName: font};
}

- (NSAttributedString *)attributeString {
    if (!_mutableAttrStr) {
        return [[NSAttributedString alloc] init];
    }
    return [_mutableAttrStr copy];
}

- (NSMutableArray<JHParserDrawTask *> *)drawTasks {
    if (!_drawTasks) {
        _drawTasks = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _drawTasks;
}

- (NSDictionary<NSNumber *, NSParagraphStyle *> *)paragraphStyles {
    if (!_paragraphStyles) {
        NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
        titleStyle.headIndent = 0;
        titleStyle.lineSpacing = 8;
        titleStyle.paragraphSpacing = 16;
        titleStyle.alignment = NSTextAlignmentLeft;
        
        NSMutableParagraphStyle *blockQuoteStyle = [[NSMutableParagraphStyle alloc] init];
        blockQuoteStyle.headIndent = 16;
        blockQuoteStyle.firstLineHeadIndent = 16;
        blockQuoteStyle.lineSpacing = 8;
        blockQuoteStyle.paragraphSpacing = 16;
        blockQuoteStyle.alignment = NSTextAlignmentLeft;
        
        NSMutableParagraphStyle *codeQuoteStyle = [[NSMutableParagraphStyle alloc] init];
        codeQuoteStyle.headIndent = 16;
        codeQuoteStyle.firstLineHeadIndent = 16;
        codeQuoteStyle.lineSpacing = 8;
        codeQuoteStyle.paragraphSpacing = 0;
        codeQuoteStyle.alignment = NSTextAlignmentLeft;
        
        NSMutableParagraphStyle *listItemStyle = [[NSMutableParagraphStyle alloc] init];
        listItemStyle.lineSpacing = 8;
        listItemStyle.paragraphSpacing = 16;
        listItemStyle.alignment = NSTextAlignmentLeft;
        
        NSMutableParagraphStyle *noneStyle = [[NSMutableParagraphStyle alloc] init];
        noneStyle.lineSpacing = 8;
        noneStyle.paragraphSpacing = 16;
        noneStyle.alignment = NSTextAlignmentLeft;
        
        _paragraphStyles = @{
                             @(JHDraftTextTypeH1):[titleStyle copy],
                             @(JHDraftTextTypeH2):[titleStyle copy],
                             @(JHDraftTextTypeH3):[titleStyle copy],
                             @(JHDraftTextTypeH4):[titleStyle copy],
                             @(JHDraftTextTypeH5):[titleStyle copy],
                             @(JHDraftTextTypeH6):[titleStyle copy],
                             @(JHDraftTextTypeBlockQuote):[blockQuoteStyle copy],
                             @(JHDraftTextTypeCodeQuote):[codeQuoteStyle copy],
                             @(JHDraftTextTypeOrderListItem):[listItemStyle copy],
                             @(JHDraftTextTypeUnorderListItem):[listItemStyle copy],
                             @(JHDraftTextTypeNone):[noneStyle copy]
                             };
    }
    
    return _paragraphStyles;
}

- (NSDictionary<NSNumber *, NSString *> *)fonts {
    if (!_fonts) {
        _fonts = @{
                   @(JHDraftTextStyleNone):@"Helvetica",
                   @(JHDraftTextStyleBold):@"Helvetica-Bold",
                   @(JHDraftTextStyleItalic):@"Helvetica-Oblique",
                   @(JHDraftTextStyleBold&JHDraftTextStyleItalic):@"Helvetica-BoldOblique"};
    }
    
    return _fonts;
}

- (NSDictionary<NSNumber *, NSNumber *> *)fontSizes {
    if (!_fontSizes) {
        CGFloat bodyFontSize = 17;
        _fontSizes = @{
                       @(JHDraftTextTypeNone) : @(bodyFontSize),
                       @(JHDraftTextTypeH1) : @(bodyFontSize*2.0),
                       @(JHDraftTextTypeH2) : @(bodyFontSize*1.7),
                       @(JHDraftTextTypeH3) : @(bodyFontSize*1.4),
                       @(JHDraftTextTypeH4) : @(bodyFontSize*1.2),
                       @(JHDraftTextTypeH5) : @(bodyFontSize*1),
                       @(JHDraftTextTypeH6) : @(bodyFontSize*0.8),
                       @(JHDraftTextTypeOrderListItem) : @(bodyFontSize),
                       @(JHDraftTextTypeUnorderListItem) : @(bodyFontSize),
                       @(JHDraftTextTypeBlockQuote) : @(bodyFontSize),
                       @(JHDraftTextTypeCodeQuote) : @(bodyFontSize),
                       @(JHDraftTextTypeAtomic) : @(bodyFontSize),};
    }
    
    return _fontSizes;
}

@end

@implementation JHParserDrawTask

@end
