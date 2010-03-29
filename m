From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Mar 2010 17:59:47 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20100329175947.24414.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-29 17:59:47

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix --alloc contiguous policy only to allocate one set of parallel areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1487&r2=1.1488
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.217&r2=1.218

--- LVM2/WHATS_NEW	2010/03/29 16:09:40	1.1487
+++ LVM2/WHATS_NEW	2010/03/29 17:59:46	1.1488
@@ -1,10 +1,10 @@
 Version 2.02.63 -  
 ================================
+  Fix --alloc contiguous policy only to allocate one set of parallel areas.
   Do not allow {vg|lv}change --ignoremonitoring if on clustered VG.
   Improved dependency tracking for dmeventd and liblvm2cmd sources.
   Improved Makefile rules for distclean and cflow targets.
   Add ability to create mirrored logs for mirror LVs.
-  Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
   Fix clvmd cluster propagation of dmeventd monitoring mode.
   Allow ALLOC_ANYWHERE to split contiguous areas.
   Use INTERNAL_ERROR for internal errors throughout tree.
--- LVM2/lib/metadata/lv_manip.c	2010/03/26 22:15:43	1.217
+++ LVM2/lib/metadata/lv_manip.c	2010/03/29 17:59:46	1.218
@@ -1243,7 +1243,7 @@
 					  log_needs_allocating, ix_log_offset))
 			return_0;
 
-	} while (!contiguous && *allocated != needed && can_split);
+	} while ((alloc != ALLOC_CONTIGUOUS) && *allocated != needed && can_split);
 
 	return 1;
 }


