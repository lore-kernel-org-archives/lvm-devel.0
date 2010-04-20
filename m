From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2010 22:31:36 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100420223136.5904.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-20 22:31:36

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	Add a regex optimisation pass for shared character prefixes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.360&r2=1.361

--- LVM2/WHATS_NEW_DM	2010/04/20 13:58:22	1.360
+++ LVM2/WHATS_NEW_DM	2010/04/20 22:31:36	1.361
@@ -1,5 +1,6 @@
 Version 1.02.47 -
 =================================
+  Add a regex optimisation pass for shared character prefixes.
   Add dm_bit_and and dm_bitset_equal to libdevmapper.
   Simplify dm_bitset_create.
   Speed up dm_bit_get_next with ffs().


