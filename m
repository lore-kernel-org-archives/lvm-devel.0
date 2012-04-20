From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 20 Apr 2012 14:17:45 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120420141745.12909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-20 14:17:44

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Unlike 'mirror' segtype, 'raid1' should perform flush	on suspend.
	
	The 'mirror' segtype and 'raid1' segtype both set the 'MIRRORED' flag.
	However, due to differences in the way these device-mapper targets behave
	'mirror' must be suspended with the 'noflush' option and 'raid1' does not
	have to be.
	
	This patch ensures that when the 'MIRRORED' flag is checked to see if
	'noflush' is needed that it does not also set it for 'raid1' by mistake.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2385&r2=1.2386
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.276&r2=1.277

--- LVM2/WHATS_NEW	2012/04/18 15:26:02	1.2385
+++ LVM2/WHATS_NEW	2012/04/20 14:17:44	1.2386
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Unlike 'mirror' segtype, 'raid1' should perform flush on suspend.
   Add udev info and context to lvmdump.
   Fix RAID device replacement code so that it works under snapshot.
   Fix inability to split RAID1 image while specifying a particular PV.
--- LVM2/lib/activate/dev_manager.c	2012/03/14 17:12:05	1.276
+++ LVM2/lib/activate/dev_manager.c	2012/04/20 14:17:44	1.277
@@ -2178,7 +2178,8 @@
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE))
+		if (!dm->flush_required && !seg_is_raid(first_seg(lv)) &&
+		    (lv->status & MIRRORED) && !(lv->status & PVMOVE))
 			dm_tree_use_no_flush_suspend(root);
 		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:


