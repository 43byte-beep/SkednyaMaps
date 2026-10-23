#import "SKTileLoader.h"
#import "SKLocalization.h"

#define SK_TILE_CACHE_LIMIT 64

static NSCache *SKImageCache = nil;
static NSMutableSet *SKPendingTiles = nil;
static NSOperationQueue *SKTileQueue = nil;

@implementation SKTileLoader

+ (void)initialize
{
    if (self == [SKTileLoader class])
    {
        SKImageCache =
            [[NSCache alloc] init];

        [SKImageCache setCountLimit:
            SK_TILE_CACHE_LIMIT];

        SKPendingTiles =
            [[NSMutableSet alloc] init];

        SKTileQueue =
            [[NSOperationQueue alloc] init];

        /*
         * На старом iPhone не создаём
         * десятки одновременных сетевых запросов.
         */

        [SKTileQueue setMaxConcurrentOperationCount:3];
    }
}

+ (NSString *)cacheDirectory
{
    NSArray *paths =
        NSSearchPathForDirectoriesInDomains(
            NSCachesDirectory,
            NSUserDomainMask,
            YES
        );

    NSString *directory =
        [[paths objectAtIndex:0]
            stringByAppendingPathComponent:
                @"SkednyaTiles"];

    BOOL isDirectory = NO;

    if (![[NSFileManager defaultManager]
            fileExistsAtPath:directory
            isDirectory:&isDirectory])
    {
        [[NSFileManager defaultManager]
            createDirectoryAtPath:directory
            withIntermediateDirectories:YES
            attributes:nil
            error:nil];
    }

    return directory;
}

+ (NSString *)keyForX:(NSInteger)x
                    y:(NSInteger)y
                    z:(NSInteger)z
{
    return [NSString stringWithFormat:
                @"%ld_%ld_%ld",
                (long)z,
                (long)x,
                (long)y];
}

+ (UIImage *)cachedTileX:(NSInteger)x
                        y:(NSInteger)y
                        z:(NSInteger)z
{
    NSString *key =
        [self keyForX:x y:y z:z];

    return [SKImageCache objectForKey:key];
}

+ (void)loadTileX:(NSInteger)x
                y:(NSInteger)y
                z:(NSInteger)z
        completion:(void (^)(UIImage *image))completion
{
    NSString *key =
        [self keyForX:x y:y z:z];

    UIImage *memoryImage =
        [SKImageCache objectForKey:key];

    if (memoryImage)
    {
        if (completion)
        {
            dispatch_async(
                dispatch_get_main_queue(),
                ^{
                    completion(memoryImage);
                });
        }

        return;
    }

    @synchronized(SKPendingTiles)
    {
        if ([SKPendingTiles containsObject:key])
            return;

        [SKPendingTiles addObject:key];
    }

    [SKTileQueue
        addOperationWithBlock:
        ^{
            NSString *path =
                [[self cacheDirectory]
                    stringByAppendingPathComponent:
                        [key stringByAppendingString:@".png"]];

            NSData *data =
                [NSData dataWithContentsOfFile:path];

            UIImage *image = nil;

            /*
             * Сначала быстрый дисковый кэш.
             */

            if (data)
            {
                image =
                    [UIImage imageWithData:data];
            }

            /*
             * Если на диске нет — сеть.
             */

            if (!image)
            {
                NSString *urlString =
                    [NSString stringWithFormat:
                        @"https://tile.openstreetmap.org/%ld/%ld/%ld.png",
                        (long)z,
                        (long)x,
                        (long)y];

                NSURL *url =
                    [NSURL URLWithString:urlString];

                NSMutableURLRequest *request =
                    [NSMutableURLRequest
                        requestWithURL:url];

                [request setValue:
                    @"SkednyaMaps/1.0 (iOS 6)"
                    forHTTPHeaderField:@"User-Agent"];

                [request setTimeoutInterval:8.0];

                NSError *error = nil;

                NSData *networkData =
                    [NSURLConnection
                        sendSynchronousRequest:request
                        returningResponse:nil
                        error:&error];

                if (networkData)
                {
                    image =
                        [UIImage imageWithData:
                            networkData];

                    if (image)
                    {
                        [networkData
                            writeToFile:path
                            atomically:YES];
                    }
                }
            }

            if (image)
            {
                [SKImageCache
                    setObject:image
                    forKey:key];
            }

            @synchronized(SKPendingTiles)
            {
                [SKPendingTiles
                    removeObject:key];
            }

            if (completion)
            {
                dispatch_async(
                    dispatch_get_main_queue(),
                    ^{
                        completion(image);
                    });
            }
        }];
}

@end
