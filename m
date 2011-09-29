From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Sep 2011 08:50:56 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20110929085056.13681.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-29 08:50:55

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Just add warning about potential problem exteding dm_segtypes
	
	Since raid target is using now dm_segtypes also for search purpose.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/libdm/libdm-deptree.c	2011/09/27 22:43:41	1.113
+++ LVM2/libdm/libdm-deptree.c	2011/09/29 08:50:54	1.114
@@ -80,6 +80,11 @@
 	{ SEG_RAID6_ZR, "raid6_zr"},
 	{ SEG_RAID6_NR, "raid6_nr"},
 	{ SEG_RAID6_NC, "raid6_nc"},
+
+	/*
+	 *WARNING: Since 'raid' target overloads this 1:1 mapping table
+	 * for search do not add new enum elements past them!
+	 */
 	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
 	{ SEG_RAID6_ZR, "raid6"}, /* same as "raid6_zr" */
 	{ SEG_LAST, NULL },


