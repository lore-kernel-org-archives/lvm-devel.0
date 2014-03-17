From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:20 +0000 (UTC)
Subject: master - tests: add more help text and paths quotes
Message-ID: <20140317133320.5AFFE60EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0fc17fe1ce02182e5c6f2e8abf4f22f8468e44f2
Commit:        0fc17fe1ce02182e5c6f2e8abf4f22f8468e44f2
Parent:        d686f3856a51490194140c694fa4364a54244630
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 14 14:10:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:44 2014 +0100

tests: add more help text and paths quotes

Add LVM_VALGRDIN help text
Use proper quotes for  abs_  paths
(Assignment in makefile doesn't need them, only shell usage)
---
 test/Makefile.in |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 9335abd..4bd90c7 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -19,10 +19,10 @@ subdir = $(shell pwd|sed 's,.*/,,')
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-abs_srcdir = "@abs_srcdir@"
-abs_builddir = "@abs_builddir@"
-abs_top_builddir = "@abs_top_builddir@"
-abs_top_srcdir = "@abs_top_srcdir@"
+abs_srcdir = @abs_srcdir@
+abs_builddir = @abs_builddir@
+abs_top_builddir = @abs_top_builddir@
+abs_top_srcdir = @abs_top_srcdir@
 
 LVM_TEST_RESULTS ?= results
 export LVM_TEST_THIN_CHECK_CMD?=@THIN_CHECK_CMD@
@@ -66,7 +66,7 @@ help:
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
-	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg."
+	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg. (1)"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
 	@echo "  LVM_TEST_DIR		Where to create test files [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
@@ -78,6 +78,10 @@ help:
 	@echo "  LVM_TEST_THIN_DUMP_CMD   Command for thin_dump   [$(LVM_TEST_THIN_DUMP_CMD)]."
 	@echo "  LVM_TEST_THIN_REPAIR_CMD Command for thin_repair [$(LVM_TEST_THIN_REPAIR_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
+	@echo "  LVM_VALGRIND		Enable valgrind testing (1,2,3) execs $$"VALGRIND
+	@echo "  LVM_VALGRIND_CLVMD	Enable valgrind testing of clvmd (1)."
+	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
+	@echo "  LVM_VALGRIND_LVMETAD	Enable valgrind testing of lvmetad (1)."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  S			Skip given test (regex)."
 	@echo "  T			Run given test (regex)."
@@ -128,15 +132,15 @@ lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 
 lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	$(RM) $@-t
-	echo 'top_srcdir=$(top_srcdir)' >> $@-t
-	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
-	echo 'abs_top_srcdir=$(abs_top_srcdir)' >> $@-t
-	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
-	echo 'abs_builddir=$(abs_builddir)' >> $@-t
+	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
+	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
+	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
+	echo 'abs_srcdir="$(abs_srcdir)"' >> $@-t
+	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	echo 'export THIN=@THIN@' >> $@-t
-	echo 'export LVMETAD_PIDFILE=@LVMETAD_PIDFILE@' >> $@-t
-	echo 'export DMEVENTD_PIDFILE=@DMEVENTD_PIDFILE@' >> $@-t
+	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
+	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
 	mv $@-t $@
 
 LIB = lib/not lib/should lib/harness \


