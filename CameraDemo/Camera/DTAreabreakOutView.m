//
//  DTAreabreakOutView.m
//  xllive
//
//  Created by xiaoyuan on 16/5/13.
//  Copyright © 2016年 XunLei. All rights reserved.
//

#import "DTAreabreakOutView.h"

@implementation DTAreabreakOutView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.fillColor setFill];
    UIRectFill(rect);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);

    if (_path) {
        CGContextAddPath(context, _path);
        CGContextFillPath(context);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextAddPath(context, _path);
        [[UIColor whiteColor] setStroke];
        CGContextStrokePath(context);
    } else if (!CGRectEqualToRect(self.breakOutArea, CGRectZero)) {
        CGRect pathRect = self.breakOutArea;
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
        [path fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [[UIColor whiteColor] setStroke];
        [path stroke];
        CGContextStrokePath(context);
    }

    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

@end
