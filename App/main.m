#import <UIKit/UIKit.h>
#import "SKAppDelegate.h"
#import "SKLocalization.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    int result = UIApplicationMain(
        argc,
        argv,
        nil,
        NSStringFromClass([SKAppDelegate class])
    );

    [pool release];
    return result;
}
