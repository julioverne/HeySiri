include theos/makefiles/common.mk

TWEAK_NAME = HeySiri

HeySiri_FILES = /mnt/d/codes/heysiri/heysirihook/HeySiri.xm
HeySiri_FRAMEWORKS = CydiaSubstrate UIKit
HeySiri_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
HeySiri_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
	