From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:32 +0000 (GMT)
Subject: main - makefiles: allow using configure cppflags
Message-ID: <20230213133132.ABEC43881D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4791a4fc68c681a45bcdc5660c6e96af607fab27
Commit:        4791a4fc68c681a45bcdc5660c6e96af607fab27
Parent:        50f73de4b27c11c810c8f7aea3e36a5c947408af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 13:12:23 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

makefiles: allow using configure cppflags

Configure defines 'CPPFLAGS' and we should use defined value
for compilation.

Reported-by: debian
---
 libdm/make.tmpl.in | 5 +++--
 make.tmpl.in       | 5 +++--
 tools/Makefile.in  | 2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 92dc715d2..fb8973b6b 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -59,6 +59,7 @@ DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
 LDFLAGS ?= @LDFLAGS@
+CPPFLAGS ?= @CPPFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
@@ -412,7 +413,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 %.o: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
 	@mkdir -p $(@D)
-	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $(CPPFLAGS) $< -o $@
 
 %.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
@@ -422,7 +423,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 %.pot: %.c $(DEPS)
 	@echo "    [CC] $@"
 	@mkdir -p $(@D)
-	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
+	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $(CPPFLAGS) $< >$@
 
 %.so: %.o
 	@echo "    [CC] $(<F)"
diff --git a/make.tmpl.in b/make.tmpl.in
index 222ed671a..9f4ecc33f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -63,6 +63,7 @@ STATIC_LIBS = $(PTHREAD_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
+CPPFLAGS ?= @CPPFLAGS@
 LDFLAGS ?= @LDFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
@@ -477,7 +478,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 %.o: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
 	@mkdir -p $(@D)
-	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $(CPPFLAGS) $< -o $@
 
 %.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
@@ -487,7 +488,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 %.pot: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
 	@mkdir -p $(@D)
-	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
+	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $(CPPFLAGS)  $< >$@
 
 %.so: %.o
 	@echo "    [CC] $(<F)"
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 2a663a5b6..545b94f23 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -133,7 +133,7 @@ man-generator.c: $(srcdir)/command.c
 
 man-generator: man-generator.o
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) -o $@ $(<F)
+	$(Q) $(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $(<F)
 
 lvm.static: $(OBJECTS) lvm-static.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"

