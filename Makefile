ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPRO")
endif

#---------------------------------------------------------------------------------
# BUILD_FLAGS: List of extra build flags to add.
# NO_CTRCOMMON: Do not include ctrcommon.
# ENABLE_EXCEPTIONS: Enable C++ exceptions.
#---------------------------------------------------------------------------------
BUILD_FLAGS := -DLSB_FIRST -DHAVE_ASPRINTF -DHAVE_EXTERNAL_ZLIB -D__LIBRETRO__ -DSOUND_QUALITY=0 -DPATH_MAX=1024 -DINLINE=inline -DPSS_STYLE=1 -DFCEU_VERSION_NUMERIC=9813 -DFRONTEND_SUPPORTS_RGB565
ENABLE_EXCEPTIONS := 1
NO_CTRCOMMON := 1

include $(DEVKITPRO)/ctrcommon/tools/make_base
