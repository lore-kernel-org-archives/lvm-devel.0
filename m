From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:35:50 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100628203550.16904.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:35:49

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Before committing each mda, arrange mdas so ignored mdas get committed first.
	
	Arrange mdas so mdas that are to be ignored come first.  This is an
	optimization that ensures consistency on disk for the longest period of time.
	This was noted by agk in review of the v4 patchset of pvchange-based mda
	balance.
	
	Note the following example for an explanation of the background:
	Assume the initial state on disk is as follows:
	PV0 (v1, non-ignored)
	PV1 (v1, non-ignored)
	PV2 (v1, non-ignored)
	PV3 (v1, non-ignored)
	
	If we did not sort the list, we would have a commit sequence something like
	this:
	PV0 (v2, non-ignored)
	PV1 (v2, ignored)
	PV2 (v2, ignored)
	PV3 (v2, non-ignored)
	
	After the commit of PV0's mdas, we'd have an on-disk state like this:
	PV0 (v2, non-ignored)
	PV1 (v1, non-ignored)
	PV2 (v1, non-ignored)
	PV3 (v1, non-ignored)
	
	This is an inconsistent state of the disk. If the machine fails, the next
	time it was brought back up, the auto-correct mechanism in vg_read would
	update the metadata on PV1-PV3.  However, if possible we try to avoid
	inconsistent on-disk states.  Clearly, because we did not sort, we have
	a greater chance of on-disk inconsistency - from the time the commit of
	PV0 is complete until the time PV3 is complete.
	
	We could improve the amount of time the on-disk state is consistent by simply
	sorting the commit order as follows:
	PV1 (v2, ignored)
	PV2 (v2, ignored)
	PV0 (v2, non-ignored)
	PV3 (v2, non-ignored)
	
	Thus, after the first PV is committed (in this case PV1), on-disk we would
	have:
	PV0 (v1, non-ignored)
	PV1 (v2, ignored)
	PV2 (v1, non-ignored)
	PV3 (v1, non-ignored)
	
	This is clearly a consistent state.  PV1 will be read but the mda will be
	ignored.  All other PVs contain v1 metadata, and no auto-correct will be
	required.  In fact, if we commit all PVs with ignored mdas first, we'll
	only have an inconsistent state when we start writing non-ignored PVs,
	and thus the chances we'll get an inconsistent state on disk is much
	less with the sorted method.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.356&r2=1.357

--- LVM2/lib/metadata/metadata.c	2010/06/28 20:35:33	1.356
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:35:49	1.357
@@ -2426,10 +2426,21 @@
 
 static int _vg_commit_mdas(struct volume_group *vg)
 {
-	struct metadata_area *mda;
+	struct metadata_area *mda, *tmda;
+	struct dm_list ignored;
 	int failed = 0;
 	int cache_updated = 0;
 
+	/* Rearrange the metadata_areas_in_use so ignored mdas come first. */
+	dm_list_init(&ignored);
+	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_in_use) {
+		if (mda_is_ignored(mda))
+			dm_list_move(&ignored, &mda->list);
+	}
+	dm_list_iterate_items_safe(mda, tmda, &ignored) {
+		dm_list_move(&vg->fid->metadata_areas_in_use, &mda->list);
+	}
+
 	/* Commit to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		failed = 0;


