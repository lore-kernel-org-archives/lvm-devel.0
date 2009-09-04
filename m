From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Sep 2009 12:54:24 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW test/Makefile.i ...
Message-ID: <20090904125424.6447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-04 12:54:23

Modified files:
	.              : Makefile.in WHATS_NEW 
	test           : Makefile.in 
	test/api       : vgtest.c 
Added files:
	test           : lvm2app.sh 

Log message:
	Add lvm2app.sh to nightly testsuite.
	
	More tests to come but for now just call into vgtest.
	Fix warning in vgtest.c

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1254&r2=1.1255
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm2app.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/Makefile.in	2009/09/01 18:11:14	1.36
+++ LVM2/Makefile.in	2009/09/04 12:54:23	1.37
@@ -30,6 +30,7 @@
 
 ifeq ("@APPLIB@", "yes")
   SUBDIRS += liblvm
+  SUBDIRS += test/api
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
--- LVM2/WHATS_NEW	2009/09/02 21:40:10	1.1254
+++ LVM2/WHATS_NEW	2009/09/04 12:54:23	1.1255
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Add lvm2app.sh to nightly tests conditional upon configure --enable-applib.
   Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
   Enforce an alphabetical lock ordering for vgname locks.
   Refactor vgsplit, vgmerge, and vgrename to obey vgname ordering rules.
/cvs/lvm2/LVM2/test/lvm2app.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lvm2app.sh
+++ -	2009-09-04 12:54:24.245099000 +0000
@@ -0,0 +1,23 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests lvm2app library
+#
+
+. ./test-utils.sh
+
+aux prepare_devs 2
+
+pvcreate $dev1 $dev2
+
+echo `pwd`
+ls -lR `pwd`
+../api/vgtest $vg1 $dev1 $dev2
--- LVM2/test/Makefile.in	2009/03/16 18:28:05	1.17
+++ LVM2/test/Makefile.in	2009/09/04 12:54:23	1.18
@@ -40,7 +40,7 @@
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
 	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
-	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/dmeventd"' >> $@-t
+	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/liblvm:$(abs_top_builddir)/dmeventd"' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
@@ -52,6 +52,10 @@
 
 T = $(wildcard t-*.sh)
 
+ifeq ("@APPLIB@", "yes")
+  T += lvm2app.sh
+endif
+
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
--- LVM2/test/api/vgtest.c	2009/09/03 17:13:46	1.11
+++ LVM2/test/api/vgtest.c	2009/09/04 12:54:23	1.12
@@ -84,7 +84,7 @@
 		goto bad; \
 	}
 
-int init_vgtest(int argc, char *argv[])
+static int init_vgtest(int argc, char *argv[])
 {
 	int i;
 


