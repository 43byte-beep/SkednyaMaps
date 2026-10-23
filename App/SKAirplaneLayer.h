#import <UIKit/UIKit.h>

@interface SKAirplaneLayer : UIView
{
    NSArray *_aircraft;
    BOOL _enabled;
    BOOL _requestInFlight;
    NSTimeInterval _lastRequestTime;

    double _centerX;
    double _centerY;
    NSInteger _zoom;
}

- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;

- (void)refreshWithCenterX:(double)centerX
                   centerY:(double)centerY
                      zoom:(NSInteger)zoom;

@end
