TARGET = iphone:clang:6.1:6.1
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = SkednyaMaps

SkednyaMaps_FILES = \
    App/SKLocalization.m \
    App/main.m \
    App/SKAppDelegate.m \
    App/SKMapView.m \
    App/SKTileLoader.m \
    App/SKPinView.m \
    App/SKSearch.m \
    App/SKSettingsViewController.m \
    App/SKAirplaneLayer.m \
    App/SKBusLayer.m \
    App/SKBusScheduleViewController.m \
    App/SKRestaurantLayer.m \

SkednyaMaps_FRAMEWORKS = \
    UIKit \
    Foundation \
    OpenGLES \
    CoreGraphics \
    QuartzCore \
    CoreLocation

SkednyaMaps_LDFLAGS += -B$(THEOS)/toolchain/bin

include $(THEOS_MAKE_PATH)/application.mk


SkednyaMaps_PLIST = Info.plist
