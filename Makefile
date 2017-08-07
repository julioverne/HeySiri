include theos/makefiles/common.mk

SUBPROJECTS += heysirihook
SUBPROJECTS += heysirisettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
