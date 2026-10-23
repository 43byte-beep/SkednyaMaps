#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SKAppDelegate :
    NSObject <UIApplicationDelegate,
              UISearchBarDelegate,
              CLLocationManagerDelegate>
{
    UIWindow *_window;

    CLLocationManager *_locationManager;

    double _lastLatitude;
    double _lastLongitude;

    BOOL _hasLocation;
    BOOL _didSearch;
}

@property(nonatomic, retain) UIWindow *window;

@end
