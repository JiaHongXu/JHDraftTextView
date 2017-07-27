//
//  ViewController.m
//  DraftDemo
//
//  Created by Jiahong Xu on 2017/7/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "ViewController.h"

#import "JHDraftTextView.h"

@interface ViewController ()

@property (strong, nonatomic)  JHDraftTextView *draftView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"draft" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    _draftView = [[JHDraftTextView alloc] initWithFrame:self.view.frame];
    [_draftView setAttributedTextWithDraftJsonDic:jsonDic];
    _draftView.editable = NO;
    [self.view addSubview:_draftView];
}

- (void)viewWillLayoutSubviews {
    _draftView.frame = self.view.bounds;
}

- (void)handleTap:(UITapGestureRecognizer*)tapRecognizer {
    CGPoint tappedLocation = [tapRecognizer locationInView:self.view];
    if (CGRectContainsPoint(_draftView.frame, tappedLocation)) {
        CGPoint subViewLocation = [tapRecognizer locationInView:_draftView];
        NSLog(@"press at --%@--", [_draftView wordAtPoint:subViewLocation]);
    }
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipeRecognizer {
    CGPoint swipeLocation = [swipeRecognizer locationInView:self.view];
    if (CGRectContainsPoint(_draftView.frame, swipeLocation)) {
        CGPoint subViewLocation = [swipeRecognizer locationInView:_draftView];
        NSLog(@"swipe at --%@--", [_draftView sentenceAtPoint:subViewLocation]);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
