From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Mar 2015 07:43:30 +0000 (UTC)
Subject: master - metadata: process_each_lv_in_vg: get the list of LVs to process first, then do the processing
Message-ID: <20150324074330.0CFBE61171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9f021de0b4d2c873ef5b97d17c602d0380359fd
Commit:        c9f021de0b4d2c873ef5b97d17c602d0380359fd
Parent:        83587f0555d753bf0754d17bb6d4630111968e12
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 16 17:10:21 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 24 08:43:07 2015 +0100

metadata: process_each_lv_in_vg: get the list of LVs to process first, then do the processing

This avoids a problem in which we're using selection on LV list - we
need to do the selection on initial state and not on any intermediary
state as we process LVs one by one - some of the relations among LVs
can be gone during this processing.

For example, processing one LV can cause the other LVs to lose the
relation to this LV and hence they're not selectable anymore with
the original selection criteria as it would be if we did selection
on inital state. A perfect example is with thin snapshots:

$ lvs -o lv_name,origin,layout,role vg
  LV    Origin Layout      Role
  lvol1        thin,sparse public,origin,thinorigin,multithinorigin
  lvol2 lvol1  thin,sparse public,snapshot,thinsnapshot
  lvol3 lvol1  thin,sparse public,snapshot,thinsnapshot
  pool         thin,pool   private

$ lvremove -ff -S 'lv_name=lvol1 || origin=lvol1'
  Logical volume "lvol1" successfully removed

The lvremove command above was supposed to remove lvol1 as well as
all its snapshots which have origin=lvol1. It failed to do so, because
once we removed the origin lvol1, the lvol2 and lvol3 which were
snapshots before are not snapshots anymore - the relations change
as we're processing these LVs one by one.

If we do the selection first and then execute any concrete actions on
these LVs (which is what this patch does), the behaviour is correct
then - the selection is done on the *initial state*:

$ lvremove -ff -S 'lv_name=lvol1 || origin=lvol1'
  Logical volume "lvol1" successfully removed
  Logical volume "lvol2" successfully removed
  Logical volume "lvol3" successfully removed

Similarly for all the other situations in which relations among
LVs are being changed by processing the LVs one by one.

This patch also introduces LV_REMOVED internal LV status flag
to mark removed LVs so they're not processed further when we
iterate over collected list of LVs to be processed.

Previously, when we iterated directly over vg->lvs list to
process the LVs, we relied on the fact that once the LV is removed,
it is also removed from the vg->lvs list we're iterating over.
But that was incorrect as we shouldn't remove LVs from the list
during one iteration while we're iterating over that exact list
(dm_list_iterate_items safe can handle only one removal at
one iteration anyway, so it can't be used here).
---
 WHATS_NEW                        |    1 +
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_manip.c          |    2 ++
 lib/metadata/metadata-exported.h |   11 ++++++++++-
 tools/toollib.c                  |   23 +++++++++++++++++++----
 5 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 91c324e..4010e67 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Fix LV processing with selection to always do the selection on initial state.
 
 Version 2.02.118 - 23rd March 2015
 ==================================
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a975606..bbd47c3 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -92,6 +92,7 @@ static const struct flag _lv_flags[] = {
 	{CACHE_POOL_DATA, NULL, 0},
 	{CACHE_POOL_METADATA, NULL, 0},
 	{LV_PENDING_DELETE, NULL, 0}, /* FIXME Display like COMPATIBLE_FLAG */
+	{LV_REMOVED, NULL, 0},
 	{0, NULL, 0}
 };
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c9c1145..b9cd056 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5338,6 +5338,7 @@ int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv)
 	lvl->lv = lv;
 	lv->vg = vg;
 	dm_list_add(&vg->lvs, &lvl->list);
+	lv->status &= ~LV_REMOVED;
 
 	return 1;
 }
@@ -5350,6 +5351,7 @@ int unlink_lv_from_vg(struct logical_volume *lv)
 		return_0;
 
 	dm_list_del(&lvl->list);
+	lv->status |= LV_REMOVED;
 
 	return 1;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1555c87..75cd94f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -119,11 +119,18 @@
 #define CACHE			UINT64_C(0x0001000000000000)    /* LV - Internal use only */
 
 #define LV_PENDING_DELETE	UINT64_C(0x0004000000000000)    /* LV - Internal use only */
+#define LV_REMOVED		UINT64_C(0x0040000000000000)	/* LV - Internal use only
+								   This flag is used to mark an LV once it has
+								   been removed from the VG. It might still
+								   be referenced on internal lists of LVs.
+								   Any remaining references should check for
+								   this flag and ignore the LV is set.
+								*/
 #define LV_ERROR_WHEN_FULL	UINT64_C(0x0008000000000000)    /* LV - error when full */
 #define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
 									e.g. to prohibit allocation of a RAID image
 									on a PV already holing an image of the RAID set */
-/* Next unused flag:		UINT64_C(0x0040000000000000)    */
+/* Next unused flag:		UINT64_C(0x0080000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -222,6 +229,8 @@
 
 #define lv_is_rlog(lv)		(((lv)->status & REPLICATOR_LOG) ? 1 : 0)
 
+#define lv_is_removed(lv)	(((lv)->status & LV_REMOVED) ? 1 : 0)
+
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 4bd2339..be89450 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1957,6 +1957,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	unsigned lvargs_supplied = 0;
 	struct lv_list *lvl;
 	struct dm_str_list *sl;
+	struct dm_list final_lvs;
+	struct lv_list *final_lvl;
+
+	dm_list_init(&final_lvs);
 
 	if (!vg_check_status(vg, EXPORTED_VG)) {
 		ret_max = ECMD_FAILED;
@@ -1986,10 +1990,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	    (tags_supplied && str_list_match_list(tags_in, &vg->tags, NULL)))
 		process_all = 1;
 
-	/*
-	 * FIXME: In case of remove it goes through deleted entries,
-	 * but it works since entries are allocated from vg mem pool.
-	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
@@ -2049,6 +2049,21 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!process_lv)
 			continue;
 
+		log_very_verbose("Adding %s/%s to the list of LVs to be processed.", vg->name, lvl->lv->name);
+
+		if (!(final_lvl = dm_pool_zalloc(vg->vgmem, sizeof(struct lv_list)))) {
+			log_error("Failed to allocate final LV list item.");
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
+		final_lvl->lv = lvl->lv;
+		dm_list_add(&final_lvs, &final_lvl->list);
+	}
+
+	dm_list_iterate_items(lvl, &final_lvs) {
+		if (lv_is_removed(lvl->lv))
+			continue;
+
 		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
 
 		ret = process_single_lv(cmd, lvl->lv, handle);


