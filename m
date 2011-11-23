From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 12:19:24 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20111123121924.31341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 12:19:24

Modified files:
	.              : make.tmpl.in 

Log message:
	Split gcc warning options
	
	Use gcc warning options only for .c -> .o compilation
	So it makes the output more clear.
	
	Do not use INCLUDES and DEFS for .o -> .so.
	
	Do not use CFLAGS for deps .d generation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/make.tmpl.in	2011/11/23 12:18:42	1.126
+++ LVM2/make.tmpl.in	2011/11/23 12:19:23	1.127
@@ -113,13 +113,16 @@
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
-CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls -Wpointer-arith
+WFLAGS += -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings \
+ -Wmissing-prototypes -Wmissing-declarations -Wnested-externs \
+ -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls \
+ -Wpointer-arith
+
+#WFLAGS += -W -Wconversion -Wbad-function-cast -Wcast-qual
+#WFLAGS += -pedantic -std=gnu99
+#DEFS += -DDEBUG_CRC32
 
-#CFLAGS += -W -Wconversion -Wbad-function-cast -Wcast-qual
-#CFLAGS += -pedantic -std=gnu99
-#CFLAGS += -DDEBUG_CRC32
-
-CFLAGS += @COPTIMISE_FLAG@
+CFLAGS += -fPIC  @COPTIMISE_FLAG@
 LDFLAGS += @COPTIMISE_FLAG@
 
 ifeq ("@DEBUG@", "yes")
@@ -303,14 +306,14 @@
 $(TARGETS): $(OBJECTS)
 
 %.o: %.c
-	$(CC) -c $(INCLUDES) $(DEFS) $(CFLAGS) $< -o $@
+	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CFLAGS) $< -o $@
 
 %.pot: %.c Makefile
 	$(CC) -E $(INCLUDES) -include $(top_srcdir)/include/pogen.h \
-		$(DEFS) $(CFLAGS) $< > $@
+		$(DEFS) $(WFLAGS) $(CFLAGS) $< > $@
 
 %.so: %.o
-	$(CC) -c $(INCLUDES) $(DEFS) $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
+	$(CC) -c $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
 
 ifneq (,$(LIB_SHARED))
 
@@ -355,7 +358,7 @@
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(DEFS) $(CFLAGS) -o $@ $<; \
+	$(CC) -MM $(INCLUDES) $(DEFS) -o $@ $<; \
 	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
 	[ -s $@ ] || $(RM) $@
 
@@ -378,8 +381,8 @@
 	set -e; \
 	( cat $(srcdir)/.exported_symbols; \
 	  if test x$(EXPORTED_HEADER) != x; then \
-        	$(CC) -E -P $(INCLUDES) $(DEFS) $(CFLAGS) $(EXPORTED_HEADER) | \
-        	$(SED) -ne "/^typedef|}/!s/.*[ \*]\(\$(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
+		$(CC) -E -P $(INCLUDES) $(DEFS) $(EXPORTED_HEADER) | \
+		$(SED) -ne "/^typedef|}/!s/.*[ \*]\(\$(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
 	  fi \
 	) > $@
 


