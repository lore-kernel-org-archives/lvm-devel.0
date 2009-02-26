From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 26 Feb 2009 12:17:39 -0500
Subject: fix makefiles for clean/distclean target
Message-ID: <49A6CEB3.5050700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Updated makefiles to remove all files generated during building
process and restore a file set as they are checked out from cvs
by the distclean target.

Here is one thing. lvm2.po file is included in files checked out
from cvs, but I think that it should be generated as a target file
and it is an unnecessary file in the first place.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 Makefile.in         |    4 +++-
 libdm/Makefile.in   |    2 +-
 make.tmpl.in        |    2 +-
 scripts/Makefile.in |    3 +++
 test/Makefile.in    |    1 +
 tools/Makefile.in   |    2 +-
 6 files changed, 10 insertions(+), 4 deletions(-)

Index: LVM2.02.45/Makefile.in
===================================================================
--- LVM2.02.45.orig/Makefile.in
+++ LVM2.02.45/Makefile.in
@@ -27,14 +27,16 @@ SUBDIRS += lib tools daemons libdm
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
 	     daemons/dmeventd/plugins \
+	     daemons/dmeventd \
 	     lib/format1 \
 	     lib/format_pool \
 	     lib/locking \
 	     lib/mirror \
 	     lib/snapshot \
+	     test/api \
 	     test \
 	     po
-  DISTCLEAN_TARGETS += lib/misc/configure.h
+  DISTCLEAN_TARGETS += lib/misc/configure.h lib/misc/lvm-version.h
   DISTCLEAN_DIRS += lcov_reports*
 endif
 
Index: LVM2.02.45/scripts/Makefile.in
===================================================================
--- LVM2.02.45.orig/scripts/Makefile.in
+++ LVM2.02.45/scripts/Makefile.in
@@ -24,3 +24,6 @@ ifeq ("@FSADM@", "yes")
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm.sh \
 		$(sbindir)/fsadm
 endif
+
+distclean:
+	$(RM) Makefile clvmd_init_red_hat
Index: LVM2.02.45/test/Makefile.in
===================================================================
--- LVM2.02.45.orig/test/Makefile.in
+++ LVM2.02.45/test/Makefile.in
@@ -81,6 +81,7 @@ clean:
 	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
 
 distclean: clean
+	rm -f Makefile
 
 .PHONY: $(T) clean distclean
 .NOTPARALLEL:
Index: LVM2.02.45/tools/Makefile.in
===================================================================
--- LVM2.02.45.orig/tools/Makefile.in
+++ LVM2.02.45/tools/Makefile.in
@@ -82,7 +82,7 @@ LVMLIBS = -llvm
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
 		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
-		lvmcmdlib.o lvm-static.o dmsetup.o
+		lvmcmdlib.o lvm-static.o dmsetup.o dmsetup
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
Index: LVM2.02.45/make.tmpl.in
===================================================================
--- LVM2.02.45.orig/make.tmpl.in
+++ LVM2.02.45/make.tmpl.in
@@ -244,7 +244,7 @@ distclean: $(SUBDIRS.distclean)
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
-	      lvm-version.h lvm2.po
+	      lvm-version.h
 
 .export.sym: .exported_symbols
 	set -e; (echo "Base {"; echo "	global:"; \
Index: LVM2.02.45/libdm/Makefile.in
===================================================================
--- LVM2.02.45.orig/libdm/Makefile.in
+++ LVM2.02.45/libdm/Makefile.in
@@ -101,6 +101,6 @@ $(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LI
 .PHONY: distclean_lib distclean
 
 distclean_lib:
-	$(RM) libdevmapper.pc
+	$(RM) libdevmapper.so libdevmapper.pc
 
 distclean: distclean_lib


