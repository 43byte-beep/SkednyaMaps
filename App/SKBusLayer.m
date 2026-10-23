#import "SKBusLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "SKLocalization.h"

#define SK_BUS_MIN_ZOOM 10
#define SK_BUS_MAX_COUNT 80

@implementation SKBusLayer

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hit =
        [super hitTest:point withEvent:event];

    if (hit == self)
        return nil;

    return hit;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;

        _stops = [[NSArray alloc] init];
        _enabled = YES;
        _requestInFlight = NO;
        _lastRequestTime = 0.0;
    }

    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;

    if (!_enabled)
    {
        self.hidden = YES;
        [self clearMarkers];
    }
    else
    {
        self.hidden = NO;
        [self updateMarkers];
    }
}

- (void)clearMarkers
{
    NSArray *views =
        [[self.subviews copy] autorelease];

    for (UIView *view in views)
        [view removeFromSuperview];
}

- (double)xForLongitude:(double)longitude
{
    return (longitude + 180.0) / 360.0;
}

- (double)yForLatitude:(double)latitude
{
    double radians =
        latitude * M_PI / 180.0;

    return
        (1.0 -
         log(tan(radians) +
             1.0 / cos(radians)) / M_PI) / 2.0;
}

- (double)longitudeForX:(double)x
{
    return x * 360.0 - 180.0;
}

- (double)latitudeForY:(double)y
{
    if (y < 0.0) y = 0.0;
    if (y > 1.0) y = 1.0;

    return
        atan(
            sinh(
                M_PI * (1.0 - 2.0 * y)
            )
        ) * 180.0 / M_PI;
}

- (void)stopTapped:(UIButton *)button
{
    NSInteger index =
        button.tag - 1;

    if (index < 0 ||
        index >= (NSInteger)[_stops count])
        return;

    NSDictionary *stop =
        [_stops objectAtIndex:index];

    NSString *name =
        [stop objectForKey:@"name"];

    NSString *routes =
        [stop objectForKey:@"routes"];

    NSString *message =
        [routes length] ?
            [NSString stringWithFormat:
                @"Маршруты: %@",
                routes] :
            @"Маршруты не указаны";

    UIAlertView *alert =
        [[UIAlertView alloc]
            initWithTitle:
                [name length] ? name : @"Остановка"
            message:message
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];

    [alert show];
    [alert release];
}

- (void)updateMarkers
{
    if (!_enabled ||
        _zoom < SK_BUS_MIN_ZOOM)
    {
        self.hidden = YES;
        [self clearMarkers];
        return;
    }

    self.hidden = NO;
    [self clearMarkers];

    double worldSize =
        (double)(1 << _zoom) * 256.0;

    CGFloat width =
        self.bounds.size.width;

    CGFloat height =
        self.bounds.size.height;

    for (NSUInteger i = 0;
         i < [_stops count] &&
         i < SK_BUS_MAX_COUNT;
         i++)
    {
        NSDictionary *stop =
            [_stops objectAtIndex:i];

        double lat =
            [[stop objectForKey:@"lat"]
                doubleValue];

        double lon =
            [[stop objectForKey:@"lon"]
                doubleValue];

        double x =
            [self xForLongitude:lon];

        double y =
            [self yForLatitude:lat];

        double dx = x - _centerX;

        if (dx > 0.5)
            dx -= 1.0;

        if (dx < -0.5)
            dx += 1.0;

        double dy = y - _centerY;

        CGFloat screenX =
            width / 2.0 +
            dx * worldSize;

        CGFloat screenY =
            height / 2.0 +
            dy * worldSize;

        if (screenX < -20.0 ||
            screenX > width + 20.0 ||
            screenY < -20.0 ||
            screenY > height + 20.0)
            continue;

        UIButton *marker =
            [UIButton buttonWithType:
                UIButtonTypeCustom];

        marker.frame =
            CGRectMake(
                screenX - 9.0,
                screenY - 9.0,
                18.0,
                18.0);

        marker.tag =
            (NSInteger)i + 1;

        marker.backgroundColor =
            [UIColor whiteColor];

        marker.layer.cornerRadius =
            9.0;

        marker.layer.borderWidth =
            1.0;

        marker.layer.borderColor =
            [UIColor blackColor].CGColor;

        [marker setTitle:@"А"
                forState:UIControlStateNormal];

        marker.titleLabel.font =
            [UIFont boldSystemFontOfSize:10.0];

        [marker setTitleColor:
            [UIColor blackColor]
            forState:UIControlStateNormal];

        [marker addTarget:self
                   action:@selector(stopTapped:)
         forControlEvents:
             UIControlEventTouchUpInside];

        [self addSubview:marker];
    }
}

- (void)refreshWithCenterX:(double)centerX
                   centerY:(double)centerY
                      zoom:(NSInteger)zoom
{
    _centerX = centerX;
    _centerY = centerY;
    _zoom = zoom;

    if (!_enabled ||
        zoom < SK_BUS_MIN_ZOOM)
    {
        self.hidden = YES;
        [self clearMarkers];
        return;
    }

    [self updateMarkers];

    NSTimeInterval now =
        [[NSDate date] timeIntervalSince1970];

    if (_requestInFlight ||
        now - _lastRequestTime < 5.0)
        return;

    _requestInFlight = YES;
    _lastRequestTime = now;

    double worldSize =
        (double)(1 << zoom) * 256.0;

    double halfX =
        (self.bounds.size.width / 2.0) /
        worldSize;

    double halfY =
        (self.bounds.size.height / 2.0) /
        worldSize;

    double west =
        [self longitudeForX:
            centerX - halfX * 1.5];

    double east =
        [self longitudeForX:
            centerX + halfX * 1.5];

    double north =
        [self latitudeForY:
            centerY - halfY * 1.5];

    double south =
        [self latitudeForY:
            centerY + halfY * 1.5];

    NSString *query =
        [NSString stringWithFormat:
            @"[out:json][timeout:8];"
             "node[highway=bus_stop]"
             "(%.6f,%.6f,%.6f,%.6f);"
             "out tags;",
             south, west, north, east];

    NSURL *url =
        [NSURL URLWithString:
            @"https://overpass-api.de/api/interpreter"];

    NSMutableURLRequest *request =
        [NSMutableURLRequest
            requestWithURL:url
            cachePolicy:
                NSURLRequestReloadIgnoringLocalCacheData
            timeoutInterval:12.0];

    [request setHTTPMethod:@"POST"];

    NSString *body =
        [NSString stringWithFormat:
            @"data=%@",
            [query
                stringByAddingPercentEscapesUsingEncoding:
                    NSUTF8StringEncoding]];

    [request setHTTPBody:
        [body dataUsingEncoding:
            NSUTF8StringEncoding]];

    [request setValue:
        @"SkednyaMaps/1.0 (iOS 6.1.3)"
        forHTTPHeaderField:@"User-Agent"];

    [NSURLConnection
        sendAsynchronousRequest:request
        queue:[NSOperationQueue mainQueue]
        completionHandler:
        ^(NSURLResponse *response,
          NSData *data,
          NSError *error)
    {
        self->_requestInFlight = NO;

        if (error || !data)
            return;

        NSError *jsonError = nil;

        NSDictionary *root =
            [NSJSONSerialization
                JSONObjectWithData:data
                options:0
                error:&jsonError];

        if (jsonError ||
            ![root isKindOfClass:
                [NSDictionary class]])
            return;

        NSArray *elements =
            [root objectForKey:@"elements"];

        if (![elements isKindOfClass:
                [NSArray class]])
            return;

        NSMutableArray *result =
            [NSMutableArray array];

        for (NSDictionary *element in elements)
        {
            NSNumber *lat =
                [element objectForKey:@"lat"];

            NSNumber *lon =
                [element objectForKey:@"lon"];

            if (!lat || !lon)
                continue;

            NSDictionary *tags =
                [element objectForKey:@"tags"];

            NSMutableDictionary *stop =
                [NSMutableDictionary dictionary];

            [stop setObject:lat forKey:@"lat"];
            [stop setObject:lon forKey:@"lon"];

            NSString *name =
                [tags objectForKey:@"name"];

            if ([name length])
                [stop setObject:name forKey:@"name"];

            NSString *routes =
                [tags objectForKey:@"route_ref"];

            if ([routes length])
                [stop setObject:routes forKey:@"routes"];

            [result addObject:stop];

            if ([result count] >=
                SK_BUS_MAX_COUNT)
                break;
        }

        [self->_stops release];

        self->_stops =
            [result copy];

        [self updateMarkers];
    }];
}

- (void)dealloc
{
    [_stops release];

    [super dealloc];
}

@end
