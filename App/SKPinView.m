#import "SKPinView.h"
#import "SKLocalization.h"

@implementation SKPinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
        self.backgroundColor = [UIColor clearColor];

    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx =
        UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(
        ctx,
        [UIColor colorWithRed:0.1
                        green:0.45
                         blue:0.95
                        alpha:1.0].CGColor);

    CGContextFillEllipseInRect(
        ctx,
        CGRectMake(4, 4, 18, 18));

    CGContextSetStrokeColorWithColor(
        ctx,
        [UIColor whiteColor].CGColor);

    CGContextSetLineWidth(ctx, 2.0);

    CGContextStrokeEllipseInRect(
        ctx,
        CGRectMake(4, 4, 18, 18));

    CGContextMoveToPoint(ctx, 13, 22);
    CGContextAddLineToPoint(ctx, 13, 30);
    CGContextStrokePath(ctx);
}

@end
