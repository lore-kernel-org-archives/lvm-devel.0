From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 19:35:51 -0000
Subject: LVM2/lib/metadata raid_manip.c
Message-ID: <20110819193551.4027.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 19:35:50

Modified files:
	lib/metadata   : raid_manip.c 

Log message:
	clarify comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/metadata/raid_manip.c	2011/08/19 15:59:15	1.10
+++ LVM2/lib/metadata/raid_manip.c	2011/08/19 19:35:50	1.11
@@ -220,7 +220,7 @@
 		    lv->vg->name, lv->name);
 	/*
 	 * Rather than wiping lv->size, we can simply
-	 * wipe '1' to remove the superblock of any previous
+	 * wipe the first sector to remove the superblock of any previous
 	 * RAID devices.  It is much quicker.
 	 */
 	if (!set_lv(lv->vg->cmd, lv, 1, 0)) {
@@ -572,7 +572,7 @@
 	return 1;
 
 fail:
-	/* Cleanly remove newly allocated LVs that failed insertion attempt */
+	/* Cleanly remove newly-allocated LVs that failed insertion attempt */
 
 	dm_list_iterate_items(lvl, &meta_lvs)
 		if (!lv_remove(lvl->lv))


