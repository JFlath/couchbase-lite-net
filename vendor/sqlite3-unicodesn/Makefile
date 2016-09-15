SQLITE3_PATH=  ../../src/StorageEngines/ForestDB/CBForest/vendor/sqlite3-unicodesn
CBFOREST_PATH   =  ../../src/StorageEngines/ForestDB/CBForest/CBForest

CC := clang

CFLAGS := $(USR_CFLAGS) \
-c \
-I$(SQLITE3_PATH)/libstemmer_c/runtime/ \
-I$(SQLITE3_PATH)/libstemmer_c/src_c/ \
-I$(SQLITE3_PATH)/ \
-DSQLITE_ENABLE_FTS4 \
-DSQLITE_ENABLE_FTS4_UNICODE61 \
-DWITH_STEMMER_english \
-DDOC_COMP \
-D_DOC_COMP \
-DHAVE_GCC_ATOMICS=1 \
-fPIC 

LDFLAGS += $(USR_LDFLAGS) -shared -Wl

SOURCES = $(CBFOREST_PATH)/sqlite_glue.o \
$(SQLITE3_PATH)/fts3_unicode2.o \
$(SQLITE3_PATH)/fts3_unicodesn.o \
$(SQLITE3_PATH)/libstemmer_c/runtime/api_sq3.o \
$(SQLITE3_PATH)/libstemmer_c/runtime/utilities_sq3.o \
$(SQLITE3_PATH)/libstemmer_c/libstemmer/libstemmer_utf8.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_danish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_dutch.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_english.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_finnish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_french.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_german.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_hungarian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_italian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_norwegian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_porter.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_portuguese.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_spanish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_1_swedish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_ISO_8859_2_romanian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_KOI8_R_russian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_danish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_dutch.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_english.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_finnish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_french.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_german.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_hungarian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_italian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_norwegian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_porter.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_portuguese.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_romanian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_russian.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_spanish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_swedish.o \
$(SQLITE3_PATH)/libstemmer_c/src_c/stem_UTF_8_turkish.o \

TARGET=libTokenizer.so

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c 
	$(CC) $(CFLAGS) -o $@ -x c $<

clean:
	rm -f $(TARGET) `find . -name *.o`
