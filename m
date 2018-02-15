From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Feb 2018 07:57:58 -0500
Subject: master - pvmove: enhance accepted states of active LVs
Message-ID: <201802151257.w1FCvwTk005110@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=552e60b3a1e35329a47d6112c548ada124b5a4e3
Commit:        552e60b3a1e35329a47d6112c548ada124b5a4e3
Parent:        a2d2fe3a8cf840fcfcd23fb0e706c3699b79b5fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 15 13:39:58 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 15 13:55:38 2018 +0100

pvmove: enhance accepted states of active LVs

Improve pvmove to accept 'locally' active LVs together with
exclusive active LVs.

In the 1st. phase it now recognizes whether exclusive pvmove is needed.
For this case only 'exclusively' or 'locally-only without remote
activative state' LVs are acceptable and all others are skipped.

During build-up of pvmove 'activation' steps are taken, so if
there is any problem we can now 'skip' LVs from pvmove operation
rather then giving-up whole pvmove operation.

Also when pvmove is restarted, recognize need of exclusive pvmove,
and use it whenever there is LV, that require exclusive activation.
---
 tools/pvmove.c |   97 +++++++++++++++++++++++++++++++-------------------------
 1 files changed, 54 insertions(+), 43 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index cbd5cb8..2a26a10 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -340,8 +340,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	uint32_t log_count = 0;
 	int lv_found = 0;
 	int lv_skipped = 0;
-	int lv_active_count = 0;
-	int lv_exclusive_count = 0;
+	int needs_exclusive = *exclusive;
+	const struct logical_volume *holder;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -392,8 +392,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			return NULL;
 		}
 
-		if (seg_is_raid(first_seg(lv)) ||
-		    seg_is_mirrored(first_seg(lv))) {
+		seg = first_seg(lv);
+
+		/* Presence of exclusive LV decides whether pvmove must be also exclusive */
+		if ((seg_only_exclusive(seg) || lv_is_origin(lv) || lv_is_cow(lv)))
+			needs_exclusive = 1;
+
+		if (seg_is_raid(seg) || seg_is_mirrored(seg)) {
 			dm_list_init(&trim_list);
 
 			if (!get_pv_list_for_lv(vg->cmd->mem, lv, &trim_list))
@@ -432,6 +437,14 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			lv_found = 1;
 		}
 
+		seg = first_seg(lv);
+
+		if (seg_is_cache(seg) || seg_is_cache_pool(seg) ||
+		    seg_is_mirrored(seg) || seg_is_raid(seg) ||
+		    seg_is_snapshot(seg) ||
+		    seg_is_thin(seg) || seg_is_thin_pool(seg))
+			continue; /* bottom-level LVs only... */
+
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
@@ -441,47 +454,36 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 
-		if (vg_is_clustered(vg) && lv_is_visible(lv)) {
-			if (lv_is_active_exclusive_locally(lv)) {
-				if (lv_active_count) {
-					log_error("Cannot move in clustered VG %s "
-						  "if some LVs are activated "
-						  "exclusively while others don't.",
-						  vg->name);
-					return NULL;
-				}
-
-				lv_exclusive_count++;
-			} else if (lv_is_active(lv)) {
-				if (seg_only_exclusive(first_seg(lv))) {
-					lv_skipped = 1;
-					log_print_unless_silent("Skipping LV %s which is active, "
-								"but not locally exclusively.",
-							display_lvname(lv));
-					continue;
-				}
-
-				if (*exclusive) {
-					log_error("Cannot move in clustered VG %s, "
-						  "clustered mirror (cmirror) not detected "
-						  "and LVs are activated non-exclusively.",
-						  vg->name);
-					return NULL;
-				}
-
-				lv_active_count++;
-			}
-		}
+		holder = lv_lock_holder(lv);
 
-		seg = first_seg(lv);
-		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
-		    seg_is_cache(seg) || seg_is_cache_pool(seg) ||
-		    seg_is_thin(seg) || seg_is_thin_pool(seg))
-			/*
-			 * Pass over top-level LVs - they were handled.
-			 * Allow sub-LVs to proceed.
+		if (needs_exclusive) {
+			/* With exclusive pvmove skip LV when:
+			 *  - is active remotely
+			 *  - is not active locally and cannot be activated exclusively locally
+                         *
+			 * Note: lvm2 can proceed with exclusive pvmove for 'just' locally active LVs
+			 * in the case it's NOT active anywhere else, since LOCKED LVs cannot be
+			 * later activated by user.
 			 */
+			if (lv_is_active_remotely(holder) ||
+			    (!lv_is_active_locally(holder) && !activate_lv_excl_local(cmd, holder))) {
+				lv_skipped = 1;
+				log_print_unless_silent("Skipping LV %s which is not locally exclusive%s.",
+							display_lvname(lv),
+							/* Report missing cmirrord cases that matterd.
+							 * With exclusive LV types cmirrord would not help. */
+							(*exclusive &&
+							 !lv_is_origin(holder) &&
+							 !seg_only_exclusive(first_seg(holder))) ?
+							" and clustered mirror (cmirror) not detected" : "");
+				continue;
+			}
+		} else if (!activate_lv(cmd, holder)) {
+			lv_skipped = 1;
+			log_print_unless_silent("Skipping LV %s which cannot be activated.",
+						display_lvname(lv));
 			continue;
+		}
 
 		if (!_insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
 					    *lvs_changed))
@@ -517,7 +519,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (lv_exclusive_count)
+	if (needs_exclusive)
 		*exclusive = 1;
 
 	return lv_mirr;
@@ -600,6 +602,8 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 	struct dm_list *lvs_changed;
 	struct logical_volume *lv_mirr;
 	struct logical_volume *lv = NULL;
+	struct lv_list *lvl;
+	const struct logical_volume *lvh;
 	const char *pv_name = pv_dev_name(pv);
 	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
@@ -661,6 +665,13 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 			goto out;
 		}
 
+		dm_list_iterate_items(lvl, lvs_changed) {
+			lvh = lv_lock_holder(lvl->lv);
+			/* Exclusive LV decides whether pvmove must be also exclusive */
+			if (lv_is_origin(lvh) || seg_only_exclusive(first_seg(lvh)))
+				exclusive = 1;
+		}
+
 		/* Ensure mirror LV is active */
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
 			log_error("ABORTING: Temporary mirror activation failed.");


