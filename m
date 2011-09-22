From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 22 Sep 2011 12:15:32 -0500
Subject: [PATCH 2 of 2] Add --nosync option to lvextend so sync of added mirror space can be skipped
In-Reply-To: <1316711625.9375.1.camel@f14.redhat.com>
References: <1316711625.9375.1.camel@f14.redhat.com>
Message-ID: <1316711732.9375.3.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add '--nosync' option to lvextend to allow mirrors to extend w/o initial resync

Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -265,6 +265,7 @@ xx(lvextend,
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
+   "\t[--nosync]\n"
    "\t[--use-policies]\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
@@ -276,7 +277,7 @@ xx(lvextend,
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
-   nofsck_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
+   nofsck_ARG, nosync_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
    stripesize_ARG, test_ARG, type_ARG, use_policies_ARG)
 
 xx(lvmchange,
Index: LVM2/tools/lvresize.c
===================================================================
--- LVM2.orig/tools/lvresize.c
+++ LVM2/tools/lvresize.c
@@ -504,6 +504,13 @@ static int _lvresize(struct cmd_context 
 
 	/* If extending, find mirrors of last segment */
 	if ((lp->extents > lv->le_count)) {
+		/*
+		 * Has the user specified that they would like the additional
+		 * extents of a mirror not to have an initial sync?
+		 */
+		if (seg_is_mirrored(first_seg(lv)) && arg_count(cmd, nosync_ARG))
+			lv->status |= LV_NOTSYNCED;
+
 		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
 			if (seg_is_mirrored(mirr_seg))
 				seg_mirrors = lv_mirror_count(mirr_seg->lv);



