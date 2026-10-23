#import <UIKit/UIKit.h>

@interface SKBusLayer : UIView
{
    NSArray *_stops;
    BOOL _enabled;
    BOOL _requestInFlight;
    NSTimeInterval _lastRequestTime;

    double _centerX;
    double _centerY;
    NSInteger _zoom;
}

- (void)setEnabled:(BOOL)enabled;
- (void)refreshWithCenterX:(double)centerX
                   centerY:(double)centerY
                      zoom:(NSInteger)zoom;

@end
