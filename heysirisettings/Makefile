include theos/makefiles/common.mk

BUNDLE_NAME = HeySiriSettings
HeySiriSettings_FILES = /mnt/d/codes/heysiri/heysirisettings/HeySiriSettingsController.mm
HeySiriSettings_INSTALL_PATH = /Library/PreferenceBundles
HeySiriSettings_FRAMEWORKS = UIKit QuartzCore CoreGraphics MessageUI Social Twitter
HeySiriSettings_PRIVATE_FRAMEWORKS = Preferences
HeySiriSettings_CFLAGS = -fobjc-arc
HeySiriSettings_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/bundle.mk

all::
