#import "SKRestaurantLayer.h"
#import "SKLocalization.h"

#define SK_RESTAURANT_MIN_ZOOM 16
#define SK_RESTAURANT_MAX_COUNT 60

@implementation SKRestaurantLayer


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.backgroundColor =
            [UIColor clearColor];

        self.userInteractionEnabled = YES;

        _restaurants =
            [[NSArray alloc] init];

        _requestInFlight = NO;
        _hasCache = NO;
        _lastRequestTime = 0.0;
    }

    return self;
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
    return
        atan(
            sinh(
                M_PI * (1.0 - 2.0 * y)
            )
        ) * 180.0 / M_PI;
}

- (BOOL)pointInsideCacheSouth:(double)south
                         west:(double)west
                        north:(double)north
                         east:(double)east
{
    if (!_hasCache)
        return NO;

    return
        south >= _cacheSouth &&
        north <= _cacheNorth &&
        west >= _cacheWest &&
        east <= _cacheEast;
}

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    /*
     * Только сами точки принимают нажатие.
     * Пустой слой не мешает pan карты.
     */

    NSArray *views =
        [[self.subviews reverseObjectEnumerator]
            allObjects];

    for (UIView *view in views)
    {
        if (CGRectContainsPoint(
                view.frame,
                point))
        {
            return
                [view hitTest:
                    [self convertPoint:
                        point
                        toView:view]
                    withEvent:event];
        }
    }

    return nil;
}

- (void)clearMarkers
{
    NSArray *views =
        [[self.subviews copy]
            autorelease];

    for (UIView *view in views)
        [view removeFromSuperview];
}

- (void)restaurantTapped:(UIButton *)button
{
    NSInteger index =
        button.tag - 1;

    if (index < 0 ||
        index >= (NSInteger)[_restaurants count])
        return;

    NSDictionary *item =
        [_restaurants objectAtIndex:index];

    NSString *name =
        [item objectForKey:@"name"];

    NSString *address =
        [item objectForKey:@"address"];

    NSString *cuisine =
        [item objectForKey:@"cuisine"];

    NSMutableString *message =
        [NSMutableString string];

    if ([cuisine length])
        [message appendFormat:
            @"Кухня: %@",
            cuisine];

    if ([address length])
    {
        if ([message length])
            [message appendString:@"\n"];

        [message appendString:address];
    }

    if (![message length])
        [message appendString:@"Ресторан"];

    UIAlertView *alert =
        [[UIAlertView alloc]
            initWithTitle:name
            message:message
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];

    [alert show];
    [alert release];
}

- (void)updatePositionsWithCenterX:(double)centerX
                            centerY:(double)centerY
                               zoom:(NSInteger)zoom
{
    if (zoom < SK_RESTAURANT_MIN_ZOOM)
    {
        self.hidden = YES;
        [self clearMarkers];
        return;
    }

    self.hidden = NO;
    [self clearMarkers];

    double worldSize =
        (double)(1 << zoom) * 256.0;

    CGFloat width =
        self.bounds.size.width;

    CGFloat height =
        self.bounds.size.height;

    for (NSUInteger i = 0;
         i < [_restaurants count] &&
         i < SK_RESTAURANT_MAX_COUNT;
         i++)
    {
        NSDictionary *item =
            [_restaurants objectAtIndex:i];

        double latitude =
            [[item objectForKey:@"lat"]
                doubleValue];

        double longitude =
            [[item objectForKey:@"lon"]
                doubleValue];

        double x =
            [self xForLongitude:longitude];

        double y =
            [self yForLatitude:latitude];

        double dx =
            x - centerX;

        if (dx > 0.5)
            dx -= 1.0;

        if (dx < -0.5)
            dx += 1.0;

        double dy =
            y - centerY;

        CGFloat screenX =
            width / 2.0 +
            dx * worldSize;

        CGFloat screenY =
            height / 2.0 +
            dy * worldSize;

        if (screenX < -25.0 ||
            screenX > width + 25.0 ||
            screenY < -25.0 ||
            screenY > height + 25.0)
            continue;

        UIButton *button =
            [UIButton buttonWithType:
                UIButtonTypeCustom];

        button.frame =
            CGRectMake(
                screenX - 10.0,
                screenY - 10.0,
                20.0,
                20.0
            );

        button.tag =
            (NSInteger)i + 1;

        button.titleLabel.font =
            [UIFont boldSystemFontOfSize:18.0];

        [button setTitle:@"●"
                forState:UIControlStateNormal];

        [button setTitleColor:
            [UIColor redColor]
            forState:UIControlStateNormal];

        [button addTarget:self
                   action:@selector(restaurantTapped:)
         forControlEvents:
             UIControlEventTouchUpInside];

        [self addSubview:button];
    }
}

- (void)refreshWithCenterX:(double)centerX
                   centerY:(double)centerY
                      zoom:(NSInteger)zoom
                     width:(CGFloat)width
                    height:(CGFloat)height
{
    if (zoom < SK_RESTAURANT_MIN_ZOOM)
    {
        self.hidden = YES;
        [self clearMarkers];
        return;
    }

    [self updatePositionsWithCenterX:centerX
                             centerY:centerY
                                zoom:zoom];

    double worldSize =
        (double)(1 << zoom) * 256.0;

    double halfX =
        (width / 2.0) / worldSize;

    double halfY =
        (height / 2.0) / worldSize;

    double paddingX =
        halfX * 1.5;

    double paddingY =
        halfY * 1.5;

    double westX =
        centerX - paddingX;

    double eastX =
        centerX + paddingX;

    double northY =
        centerY - paddingY;

    double southY =
        centerY + paddingY;

    double west =
        [self longitudeForX:westX];

    double east =
        [self longitudeForX:eastX];

    double north =
        [self latitudeForY:northY];

    double south =
        [self latitudeForY:southY];

    if ([self pointInsideCacheSouth:south
                               west:west
                              north:north
                               east:east])
        return;

    NSTimeInterval now =
        [[NSDate date]
            timeIntervalSince1970];

    if (_requestInFlight ||
        now - _lastRequestTime < 3.0)
        return;

    _lastRequestTime = now;
    _requestInFlight = YES;

    NSString *query =
        [NSString stringWithFormat:
            @"[out:json][timeout:8];"
             "("
             "node[amenity=restaurant]"
             "(%.6f,%.6f,%.6f,%.6f);"
             "way[amenity=restaurant]"
             "(%.6f,%.6f,%.6f,%.6f);"
             "relation[amenity=restaurant]"
             "(%.6f,%.6f,%.6f,%.6f);"
             ");"
             "out center tags;",
             south, west, north, east,
             south, west, north, east,
             south, west, north, east];

    NSURL *url =
        [NSURL URLWithString:
            @"https://overpass-api.de/api/interpreter"];

    NSMutableURLRequest *request =
        [NSMutableURLRequest
            requestWithURL:url
            cachePolicy:
                NSURLRequestUseProtocolCachePolicy
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
        queue:
            [NSOperationQueue mainQueue]
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

        NSMutableArray *found =
            [NSMutableArray array];

        for (NSDictionary *element in elements)
        {
            NSDictionary *tags =
                [element objectForKey:@"tags"];

            if (![tags isKindOfClass:
                    [NSDictionary class]])
                continue;

            NSString *name =
                [tags objectForKey:@"name"];

            if (![name length])
                continue;

            NSNumber *lat =
                [element objectForKey:@"lat"];

            NSNumber *lon =
                [element objectForKey:@"lon"];

            if (!lat || !lon)
            {
                NSDictionary *center =
                    [element objectForKey:@"center"];

                lat =
                    [center objectForKey:@"lat"];

                lon =
                    [center objectForKey:@"lon"];
            }

            if (!lat || !lon)
                continue;

            NSMutableDictionary *item =
                [NSMutableDictionary dictionary];

            [item setObject:name forKey:@"name"];
            [item setObject:lat forKey:@"lat"];
            [item setObject:lon forKey:@"lon"];

            NSString *cuisine =
                [tags objectForKey:@"cuisine"];

            if ([cuisine length])
                [item setObject:cuisine
                         forKey:@"cuisine"];

            NSString *street =
                [tags objectForKey:@"addr:street"];

            NSString *house =
                [tags objectForKey:@"addr:housenumber"];

            if ([street length])
            {
                NSString *address =
                    house && [house length] ?
                        [NSString stringWithFormat:
                            @"%@ %@",
                            street,
                            house] :
                        street;

                [item setObject:address
                         forKey:@"address"];
            }

            [found addObject:item];

            if ([found count] >=
                SK_RESTAURANT_MAX_COUNT)
                break;
        }

        [self->_restaurants release];

        self->_restaurants =
            [found copy];

        self->_cacheSouth = south;
        self->_cacheWest = west;
        self->_cacheNorth = north;
        self->_cacheEast = east;
        self->_hasCache = YES;

        [self updatePositionsWithCenterX:centerX
                                 centerY:centerY
                                    zoom:zoom];
    }];
}

- (void)dealloc
{
    [_restaurants release];

    [super dealloc];
}

@end
