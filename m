From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 13:36:14 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20111020133614.14955.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 13:36:13

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	Aling structure chunk on default aling size
	
	Since we use 8 bytes by default for the pool allocation,
	keep the structure aligned with this size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.514&r2=1.515

--- LVM2/WHATS_NEW_DM	2011/10/20 13:33:41	1.514
+++ LVM2/WHATS_NEW_DM	2011/10/20 13:36:13	1.515
@@ -1,6 +1,7 @@
 Version 1.02.68 -
 ==================================
-  Simplify some pointer operations in dm_free_aux() debug code..
+  Aling size of structure chunk for fast pool allocator to 8 bytes.
+  Simplify some pointer operations in dm_free_aux() debug code.
   Remove unused dbg_malloc.h file from source tree.
   Cleanup backtraces for _create_and_load_v4().
   Fix alignment warning in bitcount calculation for raid segment.


