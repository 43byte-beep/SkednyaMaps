#import "SKSearch.h"
#import <CoreFoundation/CoreFoundation.h>
#import "SKLocalization.h"

@implementation SKSearch

+ (void)search:(NSString *)query
    completion:(void (^)(double latitude,
                         double longitude,
                         NSString *name))completion
{
    CFStringRef escapedRef =
        CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (CFStringRef)query,
            NULL,
            CFSTR(":/?#[]@!$&'()*+,;="),
            kCFStringEncodingUTF8
        );

    NSString *encoded =
        [(NSString *)escapedRef copy];

    CFRelease(escapedRef);

    NSString *urlString =
        [NSString stringWithFormat:
            @"https://nominatim.openstreetmap.org/search"
             @"?q=%@&format=jsonv2&limit=1"
             @"&accept-language=ru,en",
            encoded];

    [encoded release];

    NSURL *url =
        [NSURL URLWithString:urlString];

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url];

    [request setValue:
        @"SkednyaMaps/1.0 (iOS 6)"
        forHTTPHeaderField:@"User-Agent"];

    [request setTimeoutInterval:8.0];

    dispatch_async(
        dispatch_get_global_queue(
            DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            NSError *error = nil;

            NSData *data =
                [NSURLConnection
                    sendSynchronousRequest:request
                    returningResponse:nil
                    error:&error];

            if (!data)
            {
                NSLog(@"SKSearch error: %@", error);
                return;
            }

            NSArray *results =
                [NSJSONSerialization
                    JSONObjectWithData:data
                    options:0
                    error:&error];

            if (![results isKindOfClass:[NSArray class]] ||
                [results count] == 0)
            {
                NSLog(@"SKSearch: ничего не найдено");
                return;
            }

            NSDictionary *result =
                [results objectAtIndex:0];

            double lat =
                [[result objectForKey:@"lat"]
                    doubleValue];

            double lon =
                [[result objectForKey:@"lon"]
                    doubleValue];

            NSString *name =
                [result objectForKey:@"display_name"];

            if (completion)
            {
                dispatch_async(
                    dispatch_get_main_queue(),
                    ^{
                        completion(
                            lat,
                            lon,
                            name
                        );
                    });
            }
        });
}

@end
