From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Apr 2010 09:05:52 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.pc.in
Message-ID: <20100426090552.17169.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-26 09:05:51

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.pc.in 

Log message:
	Also include udev libs in libdevmapper.pc when udev_sync is enabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.362&r2=1.363
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.pc.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW_DM	2010/04/22 20:35:24	1.362
+++ LVM2/WHATS_NEW_DM	2010/04/26 09:05:50	1.363
@@ -1,5 +1,6 @@
 Version 1.02.47 -
 =================================
+  Also include udev libs in libdevmapper.pc when udev_sync is enabled.
   Cache bitset locations to speed up _calc_states.
   Add a regex optimisation pass for shared character prefixes.
   Add dm_bit_and and dm_bitset_equal to libdevmapper.
--- LVM2/libdm/libdevmapper.pc.in	2009/10/05 12:11:30	1.3
+++ LVM2/libdm/libdevmapper.pc.in	2010/04/26 09:05:51	1.4
@@ -8,4 +8,4 @@
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Libs.private: @SELINUX_LIBS@
+Libs.private: @SELINUX_LIBS@ @UDEV_LIBS@


