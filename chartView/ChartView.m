//
//  ChartView.m
//  chartView
//
//  Created by 韩小胜 on 2018/3/12.
//  Copyright © 2018年 sun. All rights reserved.
//

#import "ChartView.h"
#define maxNum 10
#define FormWidth [[UIScreen mainScreen] bounds].size.width/(maxNum+1)
#define FormHeight FormWidth
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface ChartView()

@property (nonatomic , copy) NSArray *xDatas;
@property (nonatomic , copy) NSArray *yDatas;
@property (nonatomic , strong) NSMutableArray *fillDatas;
@property (nonatomic , strong) NSMutableArray *frameArray;

@end

@implementation ChartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _yDatas = @[@"01期",@"02期",@"03期",@"04期",@"05期",@"06期",@"07期",@"08期",@"09期",@"10期"];
        _xDatas = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
        // 选中号码数组
        _fillDatas = [NSMutableArray new];
        _frameArray = [NSMutableArray new];
        self.backgroundColor = [UIColor whiteColor];
        // 随机取选中号码
        for (NSInteger i = 0; i < _xDatas.count; i++) {
            NSString *number = [self randomFormArray:_xDatas];
            [_fillDatas addObject:number];
        }
    }
    return self;
}

- (NSString *)randomFormArray:(NSArray *)array {
    NSInteger count = array.count;
    NSInteger index = arc4random() % count;
    
    return [NSString stringWithFormat:@"%ld" , index];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // FormHeight 为格子高度 7是离上边界的距离 不设置 就会出现显示边界的线不好控制
    // 根据yData数据绘制横向线
    for (int i = 0; i <= _yDatas.count; i++) {
        if (i < _yDatas.count) {
            NSString *date = _yDatas[i];
            // 调用计算字符串宽高方法
            CGSize size = [self calculationTextIsze:date andSize:CGSizeMake(FormWidth, FormHeight)];
            [date drawInRect:CGRectMake((FormWidth-size.width)/2.0, (FormHeight-size.height)/2.0+FormHeight*i+7, FormWidth, FormHeight) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12] , NSForegroundColorAttributeName : [UIColor blackColor]}];
        }
        
        // 设置画笔颜色
        // 描边颜色
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(context, 1);
        // 画笔的起始坐标
        // 画笔移动到该点开始画线
        CGContextMoveToPoint(context, 0, i * FormHeight + 7);
        // 画直线到该点
        CGContextAddLineToPoint(context, SCREEN_WIDTH, i * FormHeight + 7);
        // 根据坐标绘制路径  kCGPathStroke：只有边框
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    // 设置彩票号码
    for (int j = 0; j <= _yDatas.count; j++) {
        if (j < maxNum) {
            for (int i = 0; i < maxNum; i++) {
                NSString *dateStr = _xDatas[j];
                CGSize size = [self calculationTextIsze:dateStr andSize:CGSizeMake(FormWidth, FormHeight)];
                [dateStr drawInRect:CGRectMake((FormWidth-size.width)/2.0+j*FormWidth+FormWidth,(FormHeight-size.height)/2.0+i*FormHeight+7, FormWidth, FormHeight) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12] , NSForegroundColorAttributeName : [UIColor blackColor]}];
            }
        }
        // 绘制纵向边界线
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, j * FormWidth , 7);
        CGContextAddLineToPoint(context, j * FormWidth, maxNum * FormWidth + 7);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    // 画填充圆
    for (int i = 0; i < _fillDatas.count; i++) {
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextSetLineWidth(context, 1);
        NSString *number = _fillDatas[i];
        for (int x = 0 ; x < _xDatas.count; x++) {
            if ([number intValue] == x) {
                // 画圆
                CGContextAddArc(context, FormWidth*x+FormWidth/2+FormWidth, FormHeight*i+FormHeight/2+7, FormHeight/2, 0, M_PI*2, 1);
                // 计算出圆的中心点
                CGPoint point = CGPointMake(FormWidth*x+FormWidth/2+FormWidth, FormHeight*i+FormHeight/2+7);
                NSString *str = NSStringFromCGPoint(point);
                // 保存圆中心的位置，给下面连线
                [_frameArray addObject:str];
                CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
                CGContextDrawPath(context, kCGPathStroke);
                
                // 填满整个圆
                CGContextAddArc(context, FormWidth*x+FormWidth/2+FormWidth, FormHeight*i+FormHeight/2+7, FormWidth/2, 0, M_PI*2, 1);
                // 设置填充颜色
                CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
                // 根据坐标绘制路径  kCGPathFill：只有填充，不绘制边框
                CGContextDrawPath(context, kCGPathFill);
                NSString *numberStr = [NSString stringWithFormat:@"%@" , number];
                CGSize size = [self calculationTextIsze:numberStr andSize:CGSizeMake(FormWidth, FormWidth)];
                // 画内容 被选中的号码
                [numberStr drawInRect:CGRectMake((FormWidth-size.width)/2.0+x*FormWidth+FormWidth,(FormHeight-size.height)/2.0+i*FormHeight+7, FormWidth, FormHeight) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor redColor]}];
            }
        }
    }
    
    // 绘制连线
    for (int i = 0; i < _frameArray.count; i++) {
        NSString *pointStr = [_frameArray objectAtIndex:i];
        CGPoint point = CGPointFromString(pointStr);
        // 设置画笔颜色
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(context, 2);
        if (i == 0) {
            // 画笔起始坐标
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
            NSString *str1 = [_frameArray objectAtIndex:i-1];
            CGPoint point1 = CGPointFromString(str1);
            CGContextMoveToPoint(context, point1.x, point1.y);
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (CGSize)calculationTextIsze:(NSString *)text andSize:(CGSize)size {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12] , NSParagraphStyleAttributeName : paragraphStyle};
    
    CGSize contentSize = [text boundingRectWithSize:CGSizeMake(size.width, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
    return contentSize;
}

@end
