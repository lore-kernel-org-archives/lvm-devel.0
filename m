From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Nov 2008 20:48:10 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in libdm/libdevma ...
Message-ID: <20081101204810.13955.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-01 20:48:09

Modified files:
	.              : WHATS_NEW configure.in 
	libdm          : libdevmapper.pc.in 

Log message:
	Use simple x.y.z library version in libdevmapper.pc

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.987&r2=1.988
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.pc.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2008/10/31 12:25:54	1.987
+++ LVM2/WHATS_NEW	2008/11/01 20:48:09	1.988
@@ -1,8 +1,9 @@
 Version 2.02.43 -
 ===================================
+  Use simplified x.y.z version number in libdevmapper.pc.
+  Merge device-mapper into the lvm2 tree.
   Remove ancient debian directory.
   Split out lvm-logging.h from log.h and lvm-globals.[ch] from log.[ch].
-  Add libdm subdirectory for libdevmapper files.
 
 Version 2.02.42 - 26th October 2008
 ===================================
--- LVM2/configure.in	2008/11/01 02:19:17	1.86
+++ LVM2/configure.in	2008/11/01 20:48:09	1.87
@@ -721,6 +721,8 @@
 DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
 AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
 
+DM_LIB_PATCHLEVEL=`cat VERSION_LIB | awk -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################
@@ -744,6 +746,7 @@
 AC_SUBST(DM_DEVICE_UID)
 AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
+AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
 AC_SUBST(GROUP)
 AC_SUBST(HAVE_LIBDL)
--- LVM2/libdm/libdevmapper.pc.in	2006/04/19 15:23:10	1.1
+++ LVM2/libdm/libdevmapper.pc.in	2008/11/01 20:48:09	1.2
@@ -5,7 +5,7 @@
 
 Name: devmapper
 Description: device-mapper library
-Version: @DM_LIB_VERSION@
+Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
 Libs.private: -lselinux -lsepol


