#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class SKAirplaneLayer;
@class SKBusLayer;
#import <OpenGLES/ES2/gl.h>

@class SKRestaurantLayer;

@interface SKMapView : UIView
{
    EAGLContext *_glContext;

    GLuint _framebuffer;
    GLuint _colorRenderbuffer;

    GLuint _program;
    GLuint _vertexShader;
    GLuint _fragmentShader;

    GLint _positionAttribute;
    GLint _texCoordAttribute;
    GLint _textureUniform;

    GLuint _placeholderTexture;

    NSMutableDictionary *_textureCache;
    NSMutableArray *_textureOrder;

    NSInteger _zoom;
    double _centerX;
    double _centerY;

    double _pinX;
    double _pinY;
    double _pinLatitude;
    double _pinLongitude;

    BOOL _hasPin;

    UIView *_pinView;
    SKRestaurantLayer *_restaurantLayer;
    CLLocationManager *_whereLocationManager;
    UIButton *_whereButton;
    UIButton *_settingsButton;
    SKAirplaneLayer *_airplaneLayer;
    SKBusLayer *_busLayer;
}


- (void)setZoom:(NSInteger)zoom;

- (void)setCenterLatitude:(double)latitude
                longitude:(double)longitude;

- (void)setPinLatitude:(double)latitude
             longitude:(double)longitude;

- (void)zoomIn;
- (void)zoomOut;


@end
