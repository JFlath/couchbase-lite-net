# File: Android.mk
LOCAL_PATH := $(call my-dir)/..

include $(CLEAR_VARS)

LOCAL_MODULE	:=	Tokenizer

SQLITE3_PATH   	:=  $(LOCAL_PATH)/../../src/StorageEngines/ForestDB/CBForest/vendor/sqlite3-unicodesn
CBFOREST_PATH		:=  $(LOCAL_PATH)/../../src/StorageEngines/ForestDB/CBForest/CBForest

LOCAL_CFLAGS    :=  -I$(SQLITE3_PATH)/libstemmer_c/runtime/ \
					-I$(SQLITE3_PATH)/libstemmer_c/src_c/ \
					-I$(SQLITE3_PATH)/ 

# For sqlite3-unicodesn
LOCAL_CFLAGS	+=	-DSQLITE_ENABLE_FTS4 \
					-DSQLITE_ENABLE_FTS4_UNICODE61 \
					-DWITH_STEMMER_english \
					-DDOC_COMP \
					-D_DOC_COMP \
					-DHAVE_GCC_ATOMICS=1

LOCAL_SRC_FILES :=  $(CBFOREST_PATH)/sqlite_glue.c \
					$(SQLITE3_PATH)/fts3_unicode2.c \
					$(SQLITE3_PATH)/fts3_unicodesn.c \
					$(SQLITE3_PATH)/libstemmer_c/runtime/api_sq3.c \
					$(SQLITE3_PATH)/libstemmer_c/runtime/utilities_sq3.c \
					$(SQLITE3_PATH)/libstemmer_c/libstemmer/libstemmer_utf8.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_danish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_dutch.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_english.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_finnish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_french.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_german.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_hungarian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_italian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_norwegian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_porter.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_portuguese.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_spanish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_swedish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_2_romanian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_KOI8_R_russian.c \
          $(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_danish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_dutch.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_english.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_finnish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_french.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_german.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_hungarian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_italian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_norwegian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_porter.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_portuguese.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_romanian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_russian.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_spanish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_swedish.c \
					$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_turkish.c

include $(BUILD_SHARED_LIBRARY)
