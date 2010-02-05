From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 5 Feb 2010 21:49:16 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20100205214916.30492.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-02-05 21:49:16

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Adding a new mimage (leg/copy) to a mirror behaves differently
	depending on if the mirror has a 'core' or 'disk' log.  When there
	is a disk log, the new leg is added by stacking a new mirror on
	top of the old (one leg is the old mirror and the other leg is the newly
	added device).  When the log is a 'core' log, the new leg is simply added
	to the existing mirror and all the devices are re-synced.
	
	The logic that handles collapsing the stacked 'disk' log mirror was
	having the effect of causing 'core' logged mirrors to begin resync'ing
	for a second time.  I have used the 'CONVERTING' flag to indicate that
	a mirror is converting by way of stacking.  This is no longer set for
	up-converting core logs.  The final 'collapse' logic can safely be skipped
	for 'core' log mirrors - getting rid of the second resync.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1420&r2=1.1421
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2010/02/03 14:08:39	1.1420
+++ LVM2/WHATS_NEW	2010/02/05 21:49:16	1.1421
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Fix inappropriate second resync when adding mimage to core-logged mirror.
   Exclude internal VG names and uuids in lists returned via liblvm interface.
   Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option.
   Add copy constructor for metadata_area.
--- LVM2/tools/lvconvert.c	2010/01/15 22:58:25	1.115
+++ LVM2/tools/lvconvert.c	2010/02/05 21:49:16	1.116
@@ -335,6 +335,9 @@
 {
 	int r = 0;
 
+	if (!(lv->status & CONVERTING))
+		return 1;
+
 	if (!collapse_mirrored_lv(lv)) {
 		log_error("Failed to remove temporary sync layer.");
 		return 0;
@@ -967,7 +970,8 @@
 			stack;
 			return failure_code;
 		}
-		lv->status |= CONVERTING;
+		if (seg->log_lv)
+			lv->status |= CONVERTING;
 		lp->need_polling = 1;
 	}
 


