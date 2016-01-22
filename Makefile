include platform.mk

LUA_CLIB_PATH ?= cel_game/luaclib

SKYSERVER_BUILD_PATH ?= .

CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS) 

# lua

LUA_INC ?= 3rd/skynet/3rd/lua

# cel_server

LUA_CLIB = cjson

all : \
  $(foreach v, $(LUA_CLIB), $(LUA_CLIB_PATH)/$(v).so) 

$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)

$(LUA_CLIB_PATH)/cjson.so : | $(LUA_CLIB_PATH)
	cd 3rd/lua-cjson && $(MAKE) LUA_INCLUDE_DIR=../../$(LUA_INC) CC=$(CC) CJSON_LDFLAGS="$(SHARED)" && cd ../.. && cp 3rd/lua-cjson/cjson.so $@

clean :
	rm -f $(LUA_CLIB_PATH)/*.so
	cd 3rd/lua-cjson && $(MAKE) clean
