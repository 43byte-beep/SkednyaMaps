#import <UIKit/UIKit.h>

extern NSString * const SKSettingsChangedNotification;

@interface SKSettingsViewController : UITableViewController

+ (BOOL)showsAirplanes;
+ (BOOL)showsBuses;

- (void)dismissSettings;

@end
