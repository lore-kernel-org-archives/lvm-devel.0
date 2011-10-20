From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 13:23:54 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/dbg_malloc.h
Message-ID: <20111020132354.1988.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 13:23:52

Modified files:
	.              : WHATS_NEW_DM 
Removed files:
	libdm/mm       : dbg_malloc.h 

Log message:
	Remove unused file from tree

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.512&r2=1.513
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.h.diff?cvsroot=lvm2&r1=1.5&r2=NONE

--- LVM2/WHATS_NEW_DM	2011/10/20 10:38:04	1.512
+++ LVM2/WHATS_NEW_DM	2011/10/20 13:23:52	1.513
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Remove unused dbg_malloc.h file from source tree.
   Cleanup backtraces for _create_and_load_v4().
   Fix alignment warning in bitcount calculation for raid segment.
   Allocate dm_tree structure from dm_tree pool.


