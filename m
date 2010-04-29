From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2010 01:48:22 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100429014822.26788.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-29 01:48:19

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.364&r2=1.365

--- LVM2/WHATS_NEW_DM	2010/04/28 13:37:36	1.364
+++ LVM2/WHATS_NEW_DM	2010/04/29 01:48:19	1.365
@@ -4,7 +4,7 @@
   Add DM_UDEV_PRIMARY_SOURCE_FLAG udev flag to recognize proper DM events.
   Also include udev libs in libdevmapper.pc when udev_sync is enabled.
   Cache bitset locations to speed up _calc_states.
-  Add a regex optimisation pass for shared character prefixes.
+  Add a regex optimisation pass for shared prefixes and suffixes.
   Add dm_bit_and and dm_bitset_equal to libdevmapper.
   Simplify dm_bitset_create.
   Speed up dm_bit_get_next with ffs().


