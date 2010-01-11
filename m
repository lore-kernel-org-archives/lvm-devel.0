From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2010 15:48:51 -0000
Subject: LVM2 ./WHATS_NEW_DM ./configure.in test/Makefi ...
Message-ID: <20100111154851.11056.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-11 15:48:50

Modified files:
	.              : WHATS_NEW_DM configure.in 
	test           : Makefile.in 

Log message:
	Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 env. variables for tests.
	
	We need to disable udev checking for our tests since they use their own
	location for device nodes and symlinks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.328&r2=1.329
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW_DM	2010/01/11 15:43:19	1.328
+++ LVM2/WHATS_NEW_DM	2010/01/11 15:48:49	1.329
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 env. variables for tests.
   Enable udev_sync and udev_rules in lvm.conf by default while running tests.
   Add support to disable udev checking: DM_UDEV_DISABLE_CHECKING=1 env. variable.
   Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
--- LVM2/configure.in	2009/10/14 04:10:41	1.120
+++ LVM2/configure.in	2010/01/11 15:48:49	1.121
@@ -1130,6 +1130,7 @@
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_RULES)
+AC_SUBST(UDEV_SYNC)
 AC_SUBST([LIB_PTHREAD])
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
--- LVM2/test/Makefile.in	2009/11/30 16:58:53	1.24
+++ LVM2/test/Makefile.in	2010/01/11 15:48:50	1.25
@@ -30,6 +30,11 @@
 
 T = $(wildcard $(srcdir)/t-*.sh)
 
+ifeq ("@UDEV_SYNC@", "yes")
+dm_udev_disable_checking = 1
+lvm_udev_disable_checking = 1
+endif
+
 ifeq ("@APPLIB@", "yes")
 T += $(srcdir)/lvm2app.sh
 all: api/vgtest
@@ -56,6 +61,8 @@
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
+	echo 'export DM_UDEV_DISABLE_CHECKING=$(dm_udev_disable_checking)' >> $@-t
+	echo 'export LVM_UDEV_DISABLE_CHECKING=$(lvm_udev_disable_checking)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
 	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \


