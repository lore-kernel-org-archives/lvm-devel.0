From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:19:23 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20111118191923.15328.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:19:23

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Skip non-virtual snapshots for availability
	
	Change the behavior of availability change.
	With this patch the lvgchange returns success
	when VG is properly changed.
	
	It skips non-virtual origins from being changes when
	only 'vg' is specified as lvchange -a parameter.
	
	Before this change we had this:
	
	$> lvs -a
	LV    VG   Attr     LSize   Pool Origin
	lvol0 mvg  owi-a-s- 128.00k
	lvol1 mvg  owi-a-s- 128.00k
	lvol2 mvg  swi-a-s-   1.25m      lvol0
	lvol3 mvg  swi-a-s-   1.25m      lvol1
	
	$> lvchange -an mvg ; echo $?
	Can't change snapshot logical volume "lvol2".
	Can't change snapshot logical volume "lvol3".
	5
	
	$> lvs -a
	LV    VG   Attr     LSize   Pool Origin
	lvol0 mvg  owi---s- 128.00k
	lvol1 mvg  owi---s- 128.00k
	lvol2 mvg  swi---s-   1.25m      lvol0
	lvol3 mvg  swi---s-   1.25m      lvol1
	
	$> lvchange -ay mvg ; echo $?
	Can't change snapshot logical volume "lvol2".
	Can't change snapshot logical volume "lvol3".
	5
	
	$> lvs
	LV    VG   Attr     LSize   Pool Origin
	lvol0 mvg  owi-a-s- 128.00k
	lvol1 mvg  owi-a-s- 128.00k
	lvol2 mvg  swi-a-s-   1.25m      lvol0
	lvol3 mvg  swi-a-s-   1.25m      lvol1
	
	After commit:
	
	$> lvs -a
	LV    VG   Attr     LSize   Pool Origin
	lvol0 mvg  owi-a-s- 128.00k
	lvol1 mvg  owi-a-s- 128.00k
	lvol2 mvg  swi-a-s-   1.25m      lvol0
	lvol3 mvg  swi-a-s-   1.25m      lvol1
	
	$> lvchange -an mvg ; echo $?
	0
	
	$> lvs -a
	LV    VG   Attr     LSize   Pool Origin
	lvol0 mvg  owi---s- 128.00k
	lvol1 mvg  owi---s- 128.00k
	lvol2 mvg  swi---s-   1.25m      lvol0
	lvol3 mvg  swi---s-   1.25m      lvol1
	
	$> lvchange -ay mvg ; echo $?
	0
	
	$> lvs -a
	LV    VG   Attr     LSize   Pool Origin
	lvol0 mvg  owi-a-s- 128.00k
	lvol1 mvg  owi-a-s- 128.00k
	lvol2 mvg  swi-a-s-   1.25m      lvol0
	lvol3 mvg  swi-a-s-   1.25m      lvol1

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2186&r2=1.2187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.235&r2=1.236

--- LVM2/WHATS_NEW	2011/11/15 17:32:12	1.2186
+++ LVM2/WHATS_NEW	2011/11/18 19:19:22	1.2187
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Skip non-virtual origins for availability change for lvchange.
   Adjusted mirror region size only for mirrors and raids.
   Reorder prompt conditions for removal of active volumes.
   Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
--- LVM2/tools/toollib.c	2011/11/12 22:44:11	1.235
+++ LVM2/tools/toollib.c	2011/11/18 19:19:22	1.236
@@ -123,6 +123,12 @@
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
+		/* Skip availability change for non-virt snaps when processing all LVs */
+		/* FIXME: pass process_all to process_single_lv() */
+		if (process_all && arg_count(cmd, available_ARG) &&
+		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
+			continue;
+
 		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 


