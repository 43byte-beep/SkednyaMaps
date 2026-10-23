#import <UIKit/UIKit.h>

@interface SKRestaurantLayer : UIView
{
    NSArray *_restaurants;
    BOOL _requestInFlight;

    double _cacheSouth;
    double _cacheWest;
    double _cacheNorth;
    double _cacheEast;
    BOOL _hasCache;

    NSTimeInterval _lastRequestTime;
}

- (void)refreshWithCenterX:(double)centerX
                   centerY:(double)centerY
                      zoom:(NSInteger)zoom
                     width:(CGFloat)width
                    height:(CGFloat)height;

- (void)updatePositionsWithCenterX:(double)centerX
                            centerY:(double)centerY
                               zoom:(NSInteger)zoom;

@end
