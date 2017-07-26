//
//  JHDraftView.m
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHDraftTextView.h"
#import "JHDraftParser.h"

@interface JHDraftTextView () <JHDraftParserDelegate>

@property (nonatomic, strong) JHDraftParser *parser;

@end

@implementation JHDraftTextView

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.editable = NO;
    self.selectable = NO;
}

#pragma mark - Public Methods

- (void)setAttributedTextWithDraftJsonDic:(NSDictionary *)jsonDic {
    self.attributedText = [self.parser attributedStringWithDraftJsonDic:jsonDic];
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

- (NSUInteger)_charIndexAtPoint:(CGPoint)point {
    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextStorage *textStorage = layoutManager.textStorage;
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

@end
