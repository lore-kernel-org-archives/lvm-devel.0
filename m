From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:24 +0000 (GMT)
Subject: main - makefiles: retry faster deps again
Message-ID: <20210302215824.836D13950405@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6846af6612674d854613e9936deb358f6c1b3cfe
Commit:        6846af6612674d854613e9936deb358f6c1b3cfe
Parent:        39eee85fff1930047a7dffe11183b4cafb6eb653
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 2 21:20:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: retry faster deps again

>From commit 29abba378520a270c3a9385724c8ef5df66497b1 we have hopefully
fixed most of troubles for deps tracking we had in past - so retry
again.

Drop explicit configure.h from DEPS - as it's automatically gathered
by gcc dependency tracking anyway.
---
 libdm/make.tmpl.in | 23 ++++++++---------------
 make.tmpl.in       | 23 ++++++++---------------
 2 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 1192e87e8..af55a7f91 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -280,7 +280,7 @@ INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include -include confi
 
 
 DEPS = $(top_builddir)/libdm/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/libdm/Makefile $(top_builddir)/include/configure.h
+       $(top_builddir)/libdm/Makefile
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
@@ -397,14 +397,16 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
+DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
+
 # still needed in 2018 for 32bit builds
 DEFS+=-D_FILE_OFFSET_BITS=64
 
-%.o: %.c
+%.o: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
-	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
-%.o: %.cpp
+%.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
 	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
@@ -462,17 +464,8 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: %.c
-	@echo "    [DEP] $(<F)"
-	$(Q) $(MKDIR_P) $(dir $@); \
-	set -e; \
-	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
-	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
-	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
-	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
-	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
-	[ -s $@ ] || $(RM) $@
+%.d:
+.PRECIOUS: %.d
 
 %.mo: %.po
 	@echo "    [MSGFMT] $(<F)"
diff --git a/make.tmpl.in b/make.tmpl.in
index 024302ff2..2611dcd90 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -300,7 +300,7 @@ INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include -include confi
 #VDO_INCLUDES=-I@VDO_INCLUDE@
 
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/Makefile $(top_builddir)/include/configure.h
+       $(top_builddir)/Makefile
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
@@ -436,14 +436,16 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
+DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
+
 # still needed in 2018 for 32bit builds
 DEFS+=-D_FILE_OFFSET_BITS=64
 
-%.o: %.c
+%.o: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
-	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
-%.o: %.cpp
+%.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
 	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
@@ -501,17 +503,8 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: %.c
-	@echo "    [DEP] $(<F)"
-	$(Q) $(MKDIR_P) $(dir $@); \
-	set -e; \
-	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
-	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
-	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
-	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
-	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
-	[ -s $@ ] || $(RM) $@
+%.d:
+.PRECIOUS: %.d
 
 %.mo: %.po
 	@echo "    [MSGFMT] $(<F)"


