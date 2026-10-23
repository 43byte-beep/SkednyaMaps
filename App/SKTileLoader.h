#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SKTileLoader : NSObject

+ (UIImage *)cachedTileX:(NSInteger)x
                        y:(NSInteger)y
                        z:(NSInteger)z;

+ (void)loadTileX:(NSInteger)x
                y:(NSInteger)y
                z:(NSInteger)z
        completion:(void (^)(UIImage *image))completion;

@end
