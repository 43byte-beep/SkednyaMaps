#import <Foundation/Foundation.h>

@interface SKSearch : NSObject

+ (void)search:(NSString *)query
    completion:(void (^)(double latitude, double longitude, NSString *name))completion;

@end
