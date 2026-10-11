THEOS_PACKAGE_SCHEME = rootless
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FrameBoost

FrameBoost_FILES = \
    Sources/FBEntry.xm \
    Sources/FBPreferences.m \
    Sources/FBFrameMonitor.m \
    Sources/FBOverlayView.m \
    Sources/FBStutterLog.m

FrameBoost_CFLAGS = \
    -fobjc-arc \
    -I$(THEOS_PROJECT_DIR)/Sources \
    -DFBVERSION=\"1.0.0\" \
    -Wall

FrameBoost_FRAMEWORKS = UIKit QuartzCore Foundation

ARCHS  = arm64
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/tweak.mk

SUBPROJECTS += prefs
include $(THEOS)/makefiles/aggregate.mk
