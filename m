From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Nov 2006 20:03:27 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure ./c ...
Message-ID: <20061120200327.15222.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-20 20:03:26

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 
	man            : Makefile.in 
Added files:
	scripts        : Makefile.in 

Log message:
	Install lvmdump by default.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.502&r2=1.503
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2006/05/16 20:53:13	1.16
+++ LVM2/Makefile.in	2006/11/20 20:03:26	1.17
@@ -16,7 +16,7 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-SUBDIRS = doc include man 
+SUBDIRS = doc include man scripts
 
 ifeq ("@INTL@", "yes")
   SUBDIRS += po
--- LVM2/WHATS_NEW	2006/11/20 19:33:03	1.502
+++ LVM2/WHATS_NEW	2006/11/20 20:03:26	1.503
@@ -1,5 +1,6 @@
 Version 2.02.15 - 20th November 2006
 ====================================
+  Install lvmdump by default.
   Fix check for snapshot module when activating snapshot.
   Fix pvremove error path for case when PV is in use.
   Warn if certain duplicate config file entries are seen.
--- LVM2/configure	2006/10/12 18:17:09	1.54
+++ LVM2/configure	2006/11/20 20:03:26	1.55
@@ -11203,7 +11203,7 @@
 
 
 ################################################################################
-                                                                                                                                                                                                                                                ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
+                                                                                                                                                                                                                                                          ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
 # tests run on this system so they can be shared between configure
@@ -11745,6 +11745,7 @@
   "lib/snapshot/Makefile" ) CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
   "man/Makefile" ) CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
   "po/Makefile" ) CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
+  "scripts/Makefile" ) CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
   "tools/Makefile" ) CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
   "tools/version.h" ) CONFIG_FILES="$CONFIG_FILES tools/version.h" ;;
   "tools/fsadm/Makefile" ) CONFIG_FILES="$CONFIG_FILES tools/fsadm/Makefile" ;;
--- LVM2/configure.in	2006/10/12 18:17:09	1.53
+++ LVM2/configure.in	2006/11/20 20:03:26	1.54
@@ -637,6 +637,7 @@
 lib/snapshot/Makefile							\
 man/Makefile							 	\
 po/Makefile								\
+scripts/Makefile								\
 tools/Makefile							 	\
 tools/version.h								\
 tools/fsadm/Makefile							\
--- LVM2/man/Makefile.in	2006/08/21 12:04:55	1.17
+++ LVM2/man/Makefile.in	2006/11/20 20:03:26	1.18
@@ -18,8 +18,8 @@
 
 MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
-	lvmchange.8 \
-	lvmdiskscan.8 lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
+	lvmchange.8 lvmdiskscan.8 lvmdump.8 \
+	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
 	lvscan.8 pvchange.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
/cvs/lvm2/LVM2/scripts/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/Makefile.in
+++ -	2006-11-20 20:03:27.671437000 +0000
@@ -0,0 +1,23 @@
+#
+# Copyright (C) 2006 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+VPATH = @srcdir@
+
+include $(top_srcdir)/make.tmpl
+
+install:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
+		$(sbindir)/lvmdump
+


