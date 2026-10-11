THEOS_PACKAGE_SCHEME = rootless
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FrameBoostPrefs

FrameBoostPrefs_FILES = \
    FBPrefBase.m \
    FBRootListController.m \
    FBMonitorPrefsController.m \
    FBOverlayPrefsController.m \
    FBProfilesPrefsController.m \
    FBDiagnosticsController.m

FrameBoostPrefs_CFLAGS = \
    -fobjc-arc \
    -DFBVERSION=\"1.0.0\"

FrameBoostPrefs_FRAMEWORKS = UIKit Foundation Preferences

ARCHS  = arm64
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/bundle.mk
