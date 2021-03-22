From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:37 +0000 (GMT)
Subject: dev-next - make: restore buildir != srcdir support
Message-ID: <20210322153937.04AFA385480A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48d04afaa2015fe285b2ae499b7f06d0b25ae00d
Commit:        48d04afaa2015fe285b2ae499b7f06d0b25ae00d
Parent:        c6a76c1ffe8321a4f2ed988fe5884541489e120f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 14:47:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:21:18 2021 +0100

make: restore buildir != srcdir support

Our new faster deps generation missed support for
buildirs != srcdir - as it can be usable to have
several builds from unchanged directory with sources.
---
 libdm/make.tmpl.in | 5 ++++-
 make.tmpl.in       | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index af55a7f91..083fba9c3 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -404,14 +404,17 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
+	@mkdir -p $(@D)
 	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
+	@mkdir -p $(@D)
 	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
-%.pot: %.c Makefile
+%.pot: %.c $(DEPS)
 	@echo "    [CC] $@"
+	@mkdir -p $(@D)
 	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
diff --git a/make.tmpl.in b/make.tmpl.in
index 2611dcd90..6f3f81915 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -443,14 +443,17 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
+	@mkdir -p $(@D)
 	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp $(DEPS)
 	@echo "    [CXX] $(<F)"
+	@mkdir -p $(@D)
 	$(Q) $(CXX) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(CXXFLAGS) $(CXXFLAGS_$@) $< -o $@
 
-%.pot: %.c Makefile
+%.pot: %.c $(DEPS)
 	@echo "    [CC] $(<F)"
+	@mkdir -p $(@D)
 	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o


