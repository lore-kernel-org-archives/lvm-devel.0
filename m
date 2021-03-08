From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:42 +0000 (GMT)
Subject: main - lv_remove: reduce commits for removed LVs
Message-ID: <20210308144642.0680A3951455@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a125a3bb505cc2f0374715f850f4c1e02c7d4e3c
Commit:        a125a3bb505cc2f0374715f850f4c1e02c7d4e3c
Parent:        ee9488488f1b97e7e3257e6490188d7ad5afafe0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 5 16:21:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:25:05 2021 +0100

lv_remove: reduce commits for removed LVs

This patch postpones update of lvm metadata for each removed
LV for later moment depending on LV type.

It also queues messages to be printed after such write & commit.

As such there is some change in the behavior - although before
prompt we do make  write&commit happens automatically in some
other error case we rather keep 'existing' state - so there
could be difference in amount of removed & commited LVs.

IMHO introduce logic is slightly better and more save.

But some cases still need the early commit - i.e. thin-removal
and fixing this needs some more thinking.

TODO: improve removal at least with the case of the whole thin-pool.
i.e. we can simply recognize removal of 'all LVs/whole VG'.
---
 lib/metadata/lv_manip.c | 42 ++++++++++++++++++++++++++++++------------
 lib/metadata/metadata.c |  9 +++++++++
 lib/metadata/vg.c       |  1 +
 lib/metadata/vg.h       |  2 ++
 tools/toollib.c         |  4 ++++
 5 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4ac95063c..b93f18e6e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6538,6 +6538,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int ask_discard;
 	struct seg_list *sl;
 	struct lv_segment *seg = first_seg(lv);
+	char msg[NAME_LEN + 300], *msg_dup;
 
 	vg = lv->vg;
 
@@ -6609,6 +6610,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if ((force == PROMPT) &&
 		    !lv_is_pending_delete(lv) &&
 		    lv_is_visible(lv)) {
+			if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
+				return 0;
 			if (yes_no_prompt("Do you really want to remove%s active "
 					  "%slogical volume %s? [y/n]: ",
 					  ask_discard ? " and DISCARD" : "",
@@ -6644,12 +6647,16 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard &&
-	    yes_no_prompt("Do you really want to remove and DISCARD "
-			  "logical volume %s? [y/n]: ",
-			  display_lvname(lv)) == 'n') {
-		log_error("Logical volume %s not removed.", display_lvname(lv));
-		return 0;
+	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard) {
+		/* try to store on disks already confirmed removals */
+		if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
+			return 0;
+		if (yes_no_prompt("Do you really want to remove and DISCARD "
+				  "logical volume %s? [y/n]: ",
+				  display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s not removed.", display_lvname(lv));
+			return 0;
+		}
 	}
 
 	if (lv_is_cache(lv) && !lv_is_pending_delete(lv)) {
@@ -6765,8 +6772,11 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	/* store it on disks */
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!pool_lv && (!strcmp(cmd->name, "lvremove") || !strcmp(cmd->name, "vgremove"))) {
+		/* With lvremove & vgremove try to postpone commit after last such LV */
+		vg->needs_write_and_commit = 1;
+		log_debug_metadata("Postponing write and commit.");
+	} else if (!vg_write(vg) || !vg_commit(vg))  /* store it on disks */
 		return_0;
 
 	/* Release unneeded blocks in thin pool */
@@ -6785,10 +6795,18 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	lockd_lv(cmd, lock_lv, "un", LDLV_PERSISTENT);
 	lockd_free_lv(cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
-	if (!suppress_remove_message && (visible || historical))
-		log_print_unless_silent("%sogical volume \"%s\" successfully removed",
-					historical ? "Historical l" : "L",
-					historical ? lv->this_glv->historical->name : lv->name);
+	if (!suppress_remove_message && (visible || historical)) {
+		(void) dm_snprintf(msg, sizeof(msg),
+				   "%sogical volume \"%s\" successfully removed",
+				   historical ? "Historical l" : "L",
+				   historical ? lv->this_glv->historical->name : lv->name);
+		if (!vg->needs_write_and_commit)
+			log_print_unless_silent("%s", msg);
+		/* Keep print message for later display with next vg_write() and vg_commit() */
+		else if (!(msg_dup = dm_pool_strdup(vg->vgmem, msg)) ||
+			 !str_list_add_no_dup_check(vg->vgmem, &vg->msg_list, msg_dup))
+			return_0;
+	}
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 692094ec8..2915c1d07 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3173,6 +3173,7 @@ static int _vg_commit_mdas(struct volume_group *vg)
 int vg_commit(struct volume_group *vg)
 {
 	struct pv_list *pvl;
+	struct dm_str_list *sl;
 	int ret;
 
 	ret = _vg_commit_mdas(vg);
@@ -3190,6 +3191,14 @@ int vg_commit(struct volume_group *vg)
 
 		/* This *is* the original now that it's commited. */
 		_vg_move_cached_precommitted_to_committed(vg);
+
+		if (vg->needs_write_and_commit){
+			/* Print buffered messages that have been finished with this commit. */
+			dm_list_iterate_items(sl, &vg->msg_list)
+				log_print_unless_silent("%s", sl->str);
+			dm_list_init(&vg->msg_list);
+			vg->needs_write_and_commit = 0;
+		}
 	}
 
 	/* If at least one mda commit succeeded, it was committed */
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index a809115f6..9a8693c0b 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -60,6 +60,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->removed_lvs);
 	dm_list_init(&vg->removed_historical_lvs);
 	dm_list_init(&vg->removed_pvs);
+	dm_list_init(&vg->msg_list);
 
 	log_debug_mem("Allocated VG %s at %p.", vg->name ? : "<no name>", (void *)vg);
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 386d5b450..fa1b03621 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -43,6 +43,7 @@ struct volume_group {
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
 	unsigned needs_backup : 1;
+	unsigned needs_write_and_commit : 1;
 	uint32_t write_count; /* count the number of vg_write calls */
 
 	/*
@@ -129,6 +130,7 @@ struct volume_group {
 	struct dm_hash_table *hostnames; /* map of creation hostnames */
 	struct logical_volume *pool_metadata_spare_lv; /* one per VG */
 	struct logical_volume *sanlock_lv; /* one per VG */
+	struct dm_list msg_list;
 };
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
diff --git a/tools/toollib.c b/tools/toollib.c
index 67422e3b4..41e722c5c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3216,6 +3216,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
+	if (vg->needs_write_and_commit && (ret_max == ECMD_PROCESSED) &&
+	    (!vg_write(vg) || !vg_commit(vg)))
+		return_0;
+
 	if (vg->needs_backup)
 		backup(vg);
 


