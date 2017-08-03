//
//  JHDraftView.m
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHDraftTextView.h"

@interface JHDraftTextView () <JHDraftParserDelegate>

@property (nonatomic, strong) NSMutableArray<CALayer *> *drawLayers;

@end

@implementation JHDraftTextView

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)setAttributedTextWithDraftJsonDic:(NSDictionary *)jsonDic {
    self.attributedText = [self.parser attributedStringWithDraftJsonDic:jsonDic];
    [self _performDrawTasks:self.parser.parserDrawTasks];
}

- (NSString *)wordAtPoint:(CGPoint)point {
    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextStorage *textStorage = layoutManager.textStorage;
    
    NSUInteger charIndex = [self _charIndexAtPoint:point];
    
    if ([[NSCharacterSet letterCharacterSet] characterIsMember:[textStorage.string characterAtIndex:charIndex]]) {
        NSRange wordCharacterRange = [self _wordThatContainsCharacter:charIndex string:textStorage.string];
        return [self.text substringWithRange:wordCharacterRange];
    } else {
        return @"";
    }
}

- (NSString *)sentenceAtPoint:(CGPoint)point {
    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextStorage *textStorage = layoutManager.textStorage;
    
    NSUInteger charIndex = [self _charIndexAtPoint:point];
    NSUInteger front = charIndex, tail = charIndex;
    
    NSMutableCharacterSet *set = [NSMutableCharacterSet newlineCharacterSet];
    [set addCharactersInString:@".。!?;；"];
    
    // look forward
    while (front>0 && ![set characterIsMember:[textStorage.string characterAtIndex:front-1]]) {
        front--;
    }
    
    // look backward
    while (tail+1<textStorage.string.length && ![set characterIsMember:[textStorage.string characterAtIndex:tail]]) {
        tail++;
    }
    
    NSRange sentenceCharacterRange = NSMakeRange(front, tail-front+1);
    NSString *sentence = [self.text substringWithRange:sentenceCharacterRange];
    sentence = [sentence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return sentence;
}

#pragma mark - Private Methods

- (void)_performDrawTasks:(NSArray<JHParserDrawTask *> *)drawTasks {
    if (!drawTasks&&drawTasks.count==0) {
        return;
    }

    for (CALayer *layers in self.drawLayers) {
        [layers removeFromSuperlayer];
    }
    
    for (JHParserDrawTask *task in drawTasks) {
        CGRect firstLineRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:task.fisrtIndex effectiveRange:nil];
        CGRect lastLineRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:task.lastIndex effectiveRange:nil];
        CGRect scaleRect = CGRectMake(CGRectGetMinX(firstLineRect), CGRectGetMinY(firstLineRect), CGRectGetWidth(firstLineRect), CGRectGetMaxY(lastLineRect)-CGRectGetMinY(firstLineRect));
        switch (task.type) {
            case JHDraftTextTypeCodeQuote:
            {
                CGRect quoteBackground = CGRectMake(scaleRect.origin.x+5, scaleRect.origin.y, CGRectGetWidth(scaleRect)-5*2, scaleRect.size.height+5);
                CALayer *quoteBackgroundLayer = [[CALayer alloc] init];
                quoteBackgroundLayer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1].CGColor;
                quoteBackgroundLayer.frame = quoteBackground;
                [self.layer insertSublayer:quoteBackgroundLayer atIndex:(unsigned)self.layer.sublayers.count];
                
                [self.drawLayers addObject:quoteBackgroundLayer];
            }
                break;
            case JHDraftTextTypeBlockQuote:
            {
                CGRect quoteLine = CGRectMake(scaleRect.origin.x+5, scaleRect.origin.y, 5, scaleRect.size.height-5);
                CALayer *quoteLineLayer = [[CALayer alloc] init];
                quoteLineLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5].CGColor;
                quoteLineLayer.frame = quoteLine;
                [self.layer insertSublayer:quoteLineLayer atIndex:(unsigned)self.layer.sublayers.count];
                [self.drawLayers addObject:quoteLineLayer];
                
                CGRect quoteBackground = CGRectMake(scaleRect.origin.x+5, scaleRect.origin.y, CGRectGetWidth(scaleRect)-5, scaleRect.size.height-5);
                CALayer *quoteBackgroundLayer = [[CALayer alloc] init];
                quoteBackgroundLayer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1].CGColor;
                quoteBackgroundLayer.frame = quoteBackground;
                [self.layer insertSublayer:quoteBackgroundLayer atIndex:(unsigned)self.layer.sublayers.count];
                [self.drawLayers addObject:quoteBackgroundLayer];
            }
                break;
                
            default:
                break;
        }
    }
}

- (NSUInteger)_charIndexAtPoint:(CGPoint)point {
    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextContainer *textContainer = self.textContainer;
    
    // to best fits the hit point
    point.y -= 4;
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    return [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
}

- (NSRange)_wordThatContainsCharacter:(NSUInteger)charIndex string:(NSString *)string {
    NSUInteger startLocation = charIndex;
    while(startLocation > 0 &&[[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:startLocation-1]]) {
        startLocation--;
    }
    NSUInteger endLocation = charIndex;
    while(endLocation < string.length &&[[NSCharacterSet letterCharacterSet] characterIsMember: [string characterAtIndex:endLocation+1]]) {
        endLocation++;
    }
    return NSMakeRange(startLocation, endLocation-startLocation+1);
}

#pragma mark - JHDraftParserDelegate

- (void)didUpdateAttributeText {
    [self setAttributedText:_parser.attributeString];
}

#pragma mark - Getter

- (JHDraftParser *)parser {
    if (!_parser) {
        _parser = [[JHDraftParser alloc] init];
        _parser.delegate = self;
    }
    
    return _parser;
}

- (NSMutableArray<CALayer *> *)drawLayers {
    if (!_drawLayers) {
        _drawLayers = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _drawLayers;
}

@end
