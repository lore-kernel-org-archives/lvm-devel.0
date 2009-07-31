From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 13:31:55 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20090731133155.29044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 13:31:54

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	configure --udevdir

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1219&r2=1.1220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2009/07/31 11:49:53	1.1219
+++ LVM2/WHATS_NEW	2009/07/31 13:31:53	1.1220
@@ -1,6 +1,7 @@
 Version 2.02.51 - 
 ================================
-  Added configure --enable-udev_rules --enable-udev_sync --with-udev-prefix.
+  Added configure --enable-udev_rules --enable-udev_sync.
+  Added configure --with-udev-prefix --with-udevdir.
   Added udev dir to hold udev rules.
   Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
--- LVM2/configure	2009/07/31 11:51:23	1.99
+++ LVM2/configure	2009/07/31 13:31:53	1.100
@@ -821,6 +821,7 @@
 with_usrlibdir
 with_usrsbindir
 with_udev_prefix
+with_udevdir
 with_dmeventd_pidfile
 with_dmeventd_path
 with_interface
@@ -1514,6 +1515,7 @@
   --with-usrlibdir=DIR
   --with-usrsbindir=DIR
   --with-udev-prefix=UPREFIX      Install udev rule files in UPREFIX [EPREFIX]
+  --with-udevdir=DIR      udev rules in DIR [UPREFIX/lib/udev/rules.d]
   --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
   --with-dmeventd-path=PATH       dmeventd path [EPREFIX/sbin/dmeventd]
   --with-interface=IFACE  Choose kernel interface (ioctl) [ioctl]
@@ -11052,7 +11054,14 @@
 fi
 
 
-udevdir='${udev_prefix}/lib/udev/rules.d'
+
+# Check whether --with-udevdir was given.
+if test "${with_udevdir+set}" = set; then
+  withval=$with_udevdir;  udevdir="$withval"
+else
+   udevdir='${udev_prefix}/lib/udev/rules.d'
+fi
+
 
 ################################################################################
 if test x$READLINE = xyes; then
--- LVM2/configure.in	2009/07/31 11:49:53	1.104
+++ LVM2/configure.in	2009/07/31 13:31:53	1.105
@@ -688,7 +688,10 @@
             [ udev_prefix="$withval"],
             [ udev_prefix='${exec_prefix}' ])
 
-udevdir='${udev_prefix}/lib/udev/rules.d'
+AC_ARG_WITH(udevdir,
+	    [  --with-udevdir=DIR      udev rules in DIR [[UPREFIX/lib/udev/rules.d]]],
+	    [ udevdir="$withval"],
+	    [ udevdir='${udev_prefix}/lib/udev/rules.d' ])
 
 ################################################################################
 dnl -- Ensure additional headers required


