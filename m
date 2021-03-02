From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:21 +0000 (GMT)
Subject: main - makefiles: fix pofile generation
Message-ID: <20210302215821.1E96B3950405@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bfa4439e1c9a342d8e0d9ee36932f2a89721342
Commit:        8bfa4439e1c9a342d8e0d9ee36932f2a89721342
Parent:        4e976d9960f28278563ba7d0cd4c3795a4eba949
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 2 01:10:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: fix pofile generation

If there is any user of --enable-nls  and wants to get
usable .po language file  -  use 'make pofile'
---
 libdm/make.tmpl.in | 2 +-
 make.tmpl.in       | 2 +-
 po/Makefile.in     | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 4a32b8f94..46916d23f 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -410,7 +410,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.pot: %.c Makefile
 	@echo "    [CC] $@"
-	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/include/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
+	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
 	@echo "    [CC] $<"
diff --git a/make.tmpl.in b/make.tmpl.in
index 2346bfda2..4bd089d24 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -449,7 +449,7 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.pot: %.c Makefile
 	@echo "    [CC] $@"
-	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/include/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
+	$(Q) $(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) -include $(top_builddir)/po/pogen.h $(DEFS) $(WFLAGS) $(CFLAGS) $< >$@
 
 %.so: %.o
 	@echo "    [CC] $<"
diff --git a/po/Makefile.in b/po/Makefile.in
index c8fa32ce7..6201f5965 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -19,7 +19,7 @@ LANGS=de
 
 #TARGETS=$(LANGS:%=lvm2_%.mo) $(LANGS:%=dm_%.mo)
 
-DM_POSOURCES = $(top_builddir)/tools/dmsetup.pot $(top_builddir)/libdm/*.pot \
+DM_POSOURCES = $(top_builddir)/libdm/dm-tools/dmsetup.pot $(top_builddir)/libdm/*.pot \
 	       $(top_builddir)/libdm/*/*.pot
 
 LVM_POSOURCES = $(top_builddir)/tools/*.pot $(top_builddir)/lib/*/*.pot


