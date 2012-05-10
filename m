From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 May 2012 08:54:35 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20120510085435.26643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-10 08:54:34

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Add missing pkg init

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2400&r2=1.2401
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.194&r2=1.195

--- LVM2/WHATS_NEW	2012/05/09 12:30:56	1.2400
+++ LVM2/WHATS_NEW	2012/05/10 08:54:33	1.2401
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Add missing pkg init --with-systemdsystemunitdir in configure.in (2.02.92).
   Fix division by zero if PV with zero PE count is used during vgcfgrestore.
   Add initial support for thin pool lvconvert.
   Fix lvrename for thin volumes (regression in for_each_sub_lv() 2.02.89).
--- LVM2/configure	2012/03/26 23:09:37	1.179
+++ LVM2/configure	2012/05/10 08:54:33	1.180
@@ -10243,7 +10243,8 @@
 if test "${with_systemdsystemunitdir+set}" = set; then :
   withval=$with_systemdsystemunitdir; systemdsystemunitdir=$withval
 else
-  pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
+  	    test x$PKGCONFIG_INIT != x1 && pkg_config_init
+	    pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
 fi
 
 
--- LVM2/configure.in	2012/03/26 23:09:38	1.194
+++ LVM2/configure.in	2012/05/10 08:54:34	1.195
@@ -1293,6 +1293,8 @@
 	    AC_HELP_STRING([--with-systemdsystemunitdir=DIR],
 			   [systemd service files in DIR]),
 	    systemdsystemunitdir=$withval,
+	    dnl -- init pkgconfig if required
+	    test x$PKGCONFIG_INIT != x1 && pkg_config_init
 	    pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd))
 
 if test -n "$pkg_systemdsystemunitdir"; then


