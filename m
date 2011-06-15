From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jun 2011 17:45:05 -0000
Subject: LVM2 lib/format_text/format-text.c lib/metadat ...
Message-ID: <20110615174505.9012.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-15 17:45:04

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 
	test           : t-lvconvert-repair-transient-dmeventd.sh 

Log message:
	Fix RHBZ 651590 (failure to lock LV results in failure to repair mirror after
	transient error), stemming from the following sequence of events:
	
	1) devices fail IO, triggering repair
	2) dmeventd starts fixing up the mirror
	3) during the downconversion, a new metadata version is written
	
	--> the devices come back online here
	
	4) the mirror device suspend/resume is called to update DM tables
	5) during the suspend/resume cycle, *pre*-commit metadata is read;
	however, since the failed devices are now back online, we get back
	inconsistent set of precommit metadata and the whole operation fails
	
	The patch relaxes the check that fails in step 5 above, namely by ignoring
	inconsistencies coming from PVs that are marked MISSING.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.457&r2=1.458
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.244&r2=1.245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/format_text/format-text.c	2011/06/01 19:29:33	1.181
+++ LVM2/lib/format_text/format-text.c	2011/06/15 17:45:02	1.182
@@ -127,6 +127,12 @@
 	return 0;
 }
 
+static struct device *_mda_get_device_raw(struct metadata_area *mda)
+{
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	return mdac->area.dev;
+}
+
 /*
  * For circular region between region_start and region_start + region_size,
  * back up one SECTOR_SIZE from 'region_ptr' and return the value.
@@ -1629,7 +1635,8 @@
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
 	.pv_analyze_mda = _pv_analyze_mda_raw,
-	.mda_locns_match = _mda_locns_match_raw
+	.mda_locns_match = _mda_locns_match_raw,
+	.mda_get_device = _mda_get_device_raw
 };
 
 static int _text_pv_setup(const struct format_type *fmt,
--- LVM2/lib/metadata/metadata.c	2011/06/01 19:29:33	1.457
+++ LVM2/lib/metadata/metadata.c	2011/06/15 17:45:03	1.458
@@ -2837,6 +2837,7 @@
 	int inconsistent_pvs = 0;
 	int inconsistent_seqno = 0;
 	int inconsistent_mdas = 0;
+	int inconsistent_mda_count = 0;
 	unsigned use_precommitted = precommitted;
 	unsigned saved_handles_missing_pvs = cmd->handles_missing_pvs;
 	struct dm_list *pvids;
@@ -2913,6 +2914,7 @@
 		return_NULL;
 
 	/* Ensure contents of all metadata areas match - else do recovery */
+	inconsistent_mda_count=0;
 	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
@@ -2922,6 +2924,7 @@
 			free_vg(vg);
 			continue;
 		}
+
 		if (!correct_vg) {
 			correct_vg = vg;
 			continue;
@@ -2940,6 +2943,9 @@
 			if (vg->seqno > correct_vg->seqno) {
 				free_vg(correct_vg);
 				correct_vg = vg;
+			} else {
+				mda->status |= MDA_INCONSISTENT;
+				++inconsistent_mda_count;
 			}
 		}
 
@@ -3067,6 +3073,7 @@
 		}
 
 		/* Ensure contents of all metadata areas match - else recover */
+		inconsistent_mda_count=0;
 		dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
 			if ((use_precommitted &&
 			     !(vg = mda->ops->vg_read_precommit(fid, vgname,
@@ -3111,6 +3118,9 @@
 				if (vg->seqno > correct_vg->seqno) {
 					free_vg(correct_vg);
 					correct_vg = vg;
+				} else {
+					mda->status |= MDA_INCONSISTENT;
+					++inconsistent_mda_count;
 				}
 			}
 
@@ -3137,13 +3147,26 @@
 		if (use_precommitted) {
 			log_error("Inconsistent pre-commit metadata copies "
 				  "for volume group %s", vgname);
-			/* FIXME: during repair, there is inconsistent flag set because some metadata areas
-			 * are missing (on missing PVs). Code should create list of missing PVs, compare it
-			 * with PV marked missing in metadata and if equals, use it as consistent vg.
-			 * For now, return precommited metadata if remainng seq match here to allow
-			 * preloading table in suspend call.
+
+			/*
+			 * Check whether all of the inconsistent MDAs were on
+			 * MISSING PVs -- in that case, we should be safe.
 			 */
-			if (!inconsistent_seqno) {
+			dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+				if (mda->status & MDA_INCONSISTENT) {
+					log_debug("Checking inconsistent MDA: %s", dev_name(mda_get_device(mda)));
+					dm_list_iterate_items(pvl, &correct_vg->pvs) {
+						if (mda_get_device(mda) == pvl->pv->dev &&
+						    (pvl->pv->status & MISSING_PV))
+							--inconsistent_mda_count;
+					}
+				}
+			}
+
+			if (inconsistent_mda_count < 0)
+				log_error(INTERNAL_ERROR "Too many inconsistent MDAs.");
+
+			if (!inconsistent_mda_count) {
 				*consistent = 0;
 				_free_pv_list(&all_pvs);
 				return correct_vg;
@@ -4285,6 +4308,13 @@
 	return mda1->ops->mda_locns_match(mda1, mda2);
 }
 
+struct device *mda_get_device(struct metadata_area *mda)
+{
+	if (!mda->ops->mda_get_device)
+		return NULL;
+	return mda->ops->mda_get_device(mda);
+}
+
 unsigned mda_is_ignored(struct metadata_area *mda)
 {
 	return (mda->status & MDA_IGNORED);
--- LVM2/lib/metadata/metadata.h	2011/06/01 19:29:33	1.244
+++ LVM2/lib/metadata/metadata.h	2011/06/15 17:45:03	1.245
@@ -175,9 +175,12 @@
 	 */
 	unsigned (*mda_locns_match)(struct metadata_area *mda1,
 				    struct metadata_area *mda2);
+
+	struct device *(*mda_get_device)(struct metadata_area *mda);
 };
 
-#define MDA_IGNORED 0x00000001
+#define MDA_IGNORED      0x00000001
+#define MDA_INCONSISTENT 0x00000002
 
 struct metadata_area {
 	struct dm_list list;
@@ -191,6 +194,7 @@
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
+struct device *mda_get_device(struct metadata_area *mda);
 
 struct format_instance_ctx {
 	uint32_t type;
--- LVM2/test/t-lvconvert-repair-transient-dmeventd.sh	2011/01/07 14:56:10	1.1
+++ LVM2/test/t-lvconvert-repair-transient-dmeventd.sh	2011/06/15 17:45:03	1.2
@@ -19,9 +19,9 @@
 aux disable_dev $dev2 $dev4
 mkfs.ext3 $DM_DEV_DIR/$vg/4way
 aux enable_dev $dev2 $dev4
-sleep 10
+sleep 3
 lvs -a -o +devices | not grep unknown
 check mirror $vg 4way
 check mirror_legs $vg 4way 2
-lvs -a -o +devices | should not grep mimage_1
-lvs -a -o +devices | should not grep mimage_3
+lvs -a -o +devices | not grep mimage_1
+lvs -a -o +devices | not grep mimage_3


