From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Oct 2011 15:32:29 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c tools ...
Message-ID: <20111006153229.6427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-06 15:32:27

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	tools          : commands.h lvresize.c 

Log message:
	Allow 'nosync' extension of mirrors.
	
	This patch allows a mirror to be extended without an initial resync of the
	extended portion.  It compliments the existing '--nosync' option to lvcreate.
	This action can be done implicitly if the mirror was created with the '--nosync'
	option, or explicitly if the '--nosync' option is used when extending the device.
	
	Here are the operational criteria:
	1) A mirror created with '--nosync' should extend with 'nosync' implicitly
	[EXAMPLE]# lvs vg; lvextend -L +5G vg/lv ; lvs vg
	LV   VG   Attr     LSize Pool Origin Snap%  Move Log     Copy%  Convert
	lv   vg   Mwi-a-m- 5.00g                         lv_mlog 100.00
	Extending 2 mirror images.
	Extending logical volume lv to 10.00 GiB
	Logical volume lv successfully resized
	LV   VG   Attr     LSize  Pool Origin Snap%  Move Log     Copy%  Convert
	lv   vg   Mwi-a-m- 10.00g                         lv_mlog 100.00
	
	2) The 'M' attribute ('M' signifies a mirror created with '--nosync', while 'm'
	signifies a mirror created w/o '--nosync') must be preserved when extending a
	mirror created with '--nosync'.  See #1 for example of 'M' attribute.
	
	3) A mirror created without '--nosync' should extend with 'nosync' only when
	'--nosync' is explicitly used when extending.
	[EXAMPLE]# lvs vg; lvextend -L +5G vg/lv; lvs vg
	LV   VG   Attr     LSize  Pool Origin Snap%  Move Log     Copy%  Convert
	lv   vg   mwi-a-m- 20.00m                         lv_mlog 100.00
	Extending 2 mirror images.
	Extending logical volume lv to 5.02 GiB
	Logical volume lv successfully resized
	LV   VG   Attr     LSize Pool Origin Snap%  Move Log     Copy%  Convert
	lv   vg   mwi-a-m- 5.02g                         lv_mlog   0.39
	vs.
	[EXAMPLE]# lvs vg; lvextend -L +5G vg/lv --nosync; lvs vg
	LV   VG   Attr     LSize  Pool Origin Snap%  Move Log     Copy%  Convert
	lv   vg   mwi-a-m- 20.00m                         lv_mlog 100.00
	Extending 2 mirror images.
	Extending logical volume lv to 5.02 GiB
	Logical volume lv successfully resized
	LV   VG   Attr     LSize Pool Origin Snap%  Move Log     Copy%  Convert
	lv   vg   Mwi-a-m- 5.02g                         lv_mlog 100.00
	
	4) The 'm' attribute must change to 'M' when extending a mirror created without
	'--nosync' is extended with the '--nosync' option.  (See #3 examples above.)
	
	5) An inactive mirror's sync percent cannot be determined definitively, so it
	must not be allowed to skip resync.  Instead, the extend should ask the user if
	they want to extend while performing a resync.
	[EXAMPLE]# lvchange -an vg/lv
	[EXAMPLE]# lvextend -L +5G vg/lv
	Extending 2 mirror images.
	Extending logical volume lv to 10.00 GiB
	vg/lv is not active.  Unable to get sync percent.
	Do full resync of extended portion of vg/lv?  [y/n]: y
	Logical volume lv successfully resized
	
	6) A mirror that is performing recovery (as opposed to an initial sync) - like
	after a failure - is not allowed to extend with either an implicit or
	explicit nosync option.  [You can simulate this with a 'corelog' mirror because
	when it is reactivated, it must be recovered every time.]
	[EXAMPLE]# lvcreate -m1 -L 5G -n lv vg --nosync --corelog
	WARNING: New mirror won't be synchronised. Don't read what you didn't write!
	Logical volume "lv" created
	[EXAMPLE]# lvs vg
	LV   VG   Attr     LSize Pool Origin Snap%  Move Log Copy%  Convert
	lv   vg   Mwi-a-m- 5.00g                             100.00
	[EXAMPLE]# lvchange -an vg/lv; lvchange -ay vg/lv; lvs vg
	LV   VG   Attr     LSize Pool Origin Snap%  Move Log Copy%  Convert
	lv   vg   Mwi-a-m- 5.00g                               0.08
	[EXAMPLE]# lvextend -L +5G vg/lv
	Extending 2 mirror images.
	Extending logical volume lv to 10.00 GiB
	vg/lv cannot be extended while it is recovering.
	
	7) If 'no' is selected in #5 or if the condition in #6 is hit, it should not
	result in the mirror being resized or the 'm/M' attribute being changed.
	
	NOTE:  A mirror created with '--nosync' behaves differently than one created
	without it when performing an extension.  The former cannot be extended when
	the mirror is recovering (unless in-active), while the latter can.  This is
	a reasonable thing to do since recovery of a mirror doesn't take long (at
	least in the case of an on-disk log) and it would cause far more time in
	degraded mode if the extension w/o '--nosync' was allowed.  It might be
	reasonable to add the ability to force the operation in the future.  This
	should /not/ force a nosync extension, but rather force a sync'ed extension.
	IOW, the user would be saying, "Yes, yes... I know recovery won't take long
	and that I'll be adding significantly to the time spent in degraded mode, but
	I need the extra space right now!".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2149&r2=1.2150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.293&r2=1.294
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/WHATS_NEW	2011/10/06 14:55:39	1.2149
+++ LVM2/WHATS_NEW	2011/10/06 15:32:26	1.2150
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add ability to extend mirrors with '--nosync' option.
   Fix splitmirror in cluster having different DM/LVM views of storage.
   Fix improper udev settings during suspend/resume for mirror sub-LVs.
   Fix vgsplit when there are mirrors that have mirrored logs.
--- LVM2/lib/metadata/lv_manip.c	2011/10/03 18:43:39	1.293
+++ LVM2/lib/metadata/lv_manip.c	2011/10/06 15:32:26	1.294
@@ -2599,10 +2599,11 @@
 			return 0;
 		}
 
-		r = _lv_extend_layered_lv(ah, lv, extents, 0,
-					  stripes, stripe_size);
+		if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
+						stripes, stripe_size)))
+			goto out;
 
-		if (r && segtype_is_thin_pool(segtype)) {
+		if (segtype_is_thin_pool(segtype)) {
 			/* FIXME: resize metadata size here for now */
 			struct logical_volume *tmeta = first_seg(lv)->pool_metadata_lv;
 			if ((r = lv_add_segment(ah, ah->area_count, 1, tmeta,
@@ -2613,7 +2614,52 @@
 			} else
 				stack;
 		}
+
+		/*
+		 * If we are expanding an existing mirror, we can skip the
+		 * resync of the extension if the LV is currently in-sync
+		 * and the LV has the LV_NOTSYNCED flag set.
+		 */
+		if ((lv->le_count != extents) &&
+		    segtype_is_mirrored(segtype) &&
+		    (lv->status & LV_NOTSYNCED)) {
+			percent_t sync_percent = PERCENT_INVALID;
+
+			if (!lv_is_active(lv)) {
+				log_print("%s/%s is not active."
+					  "  Unable to get sync percent.",
+					  lv->vg->name, lv->name);
+				if (yes_no_prompt("Do full resync of extended "
+						  "portion of %s/%s?  [y/n]: ",
+						  lv->vg->name, lv->name) == 'y')
+					goto out;
+				r = 0;
+				goto out;
+			}
+
+			r = 0;
+			if (!lv_mirror_percent(lv->vg->cmd, lv, 0,
+					       &sync_percent, NULL)) {
+				log_error("Failed to get sync percent for %s/%s",
+					  lv->vg->name, lv->name);
+				goto out;
+			} else if (sync_percent == PERCENT_100) {
+				log_verbose("Skipping initial resync for "
+					    "extended portion of %s/%s",
+					    lv->vg->name, lv->name);
+				init_mirror_in_sync(1);
+				lv->status |= LV_NOTSYNCED;
+			} else {
+				log_error("%s/%s cannot be extended while"
+					  " it is recovering.",
+					  lv->vg->name, lv->name);
+				goto out;
+			}
+			r = 1;
+		}
 	}
+
+out:
 	alloc_destroy(ah);
 	return r;
 }
--- LVM2/tools/commands.h	2011/09/06 00:26:43	1.162
+++ LVM2/tools/commands.h	2011/10/06 15:32:27	1.163
@@ -265,6 +265,7 @@
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
+   "\t[--nosync]\n"
    "\t[--use-policies]\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
@@ -276,7 +277,7 @@
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
-   nofsck_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
+   nofsck_ARG, nosync_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
    stripesize_ARG, test_ARG, type_ARG, use_policies_ARG)
 
 xx(lvmchange,
--- LVM2/tools/lvresize.c	2011/09/21 10:39:47	1.138
+++ LVM2/tools/lvresize.c	2011/10/06 15:32:27	1.139
@@ -504,6 +504,13 @@
 
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


