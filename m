From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 12:47:26 +0000 (UTC)
Subject: master - metadata: Fix metadata repair paths when lvmetad is used.
Message-ID: <20131009124726.2BCF560FF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0decd7553ac9dcf4a7d81f5b10b1f4ca053ae9a5
Commit:        0decd7553ac9dcf4a7d81f5b10b1f4ca053ae9a5
Parent:        fbb6de845e857cfb4144c40dca36456d27abdbe9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 14:04:47 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 9 14:44:01 2013 +0200

metadata: Fix metadata repair paths when lvmetad is used.

---
 lib/cache/lvmetad.c     |    2 -
 lib/metadata/metadata.c |   76 +++++++++++++++++++++++++++++++----------------
 lib/metadata/metadata.h |    3 --
 3 files changed, 50 insertions(+), 31 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f43283f..8940704 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -392,8 +392,6 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 				pvl->pv->dev = lvmcache_device(info);
 				if (!pvl->pv->dev)
 					pvl->pv->status |= MISSING_PV;
-				else
-					check_reappeared_pv(vg, pvl->pv);
 				if (!lvmcache_fid_add_mdas_pv(info, fid)) {
 					vg = NULL;
 					goto_out;	/* FIXME error path */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4ffd502..8571e0a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2883,10 +2883,11 @@ int vg_missing_pv_count(const struct volume_group *vg)
 	return ret;
 }
 
-void check_reappeared_pv(struct volume_group *correct_vg,
-			 struct physical_volume *pv)
+static int _check_reappeared_pv(struct volume_group *correct_vg,
+				struct physical_volume *pv, int act)
 {
 	struct pv_list *pvl;
+	int rv = 0;
 
         /*
          * Skip these checks in case the tool is going to deal with missing
@@ -2894,21 +2895,47 @@ void check_reappeared_pv(struct volume_group *correct_vg,
          * confusing.
          */
         if (correct_vg->cmd->handles_missing_pvs)
-            return;
+            return rv;
 
 	dm_list_iterate_items(pvl, &correct_vg->pvs)
 		if (pv->dev == pvl->pv->dev && is_missing_pv(pvl->pv)) {
-			log_warn("Missing device %s reappeared, updating "
-				 "metadata for VG %s to version %u.",
-				 pv_dev_name(pvl->pv),  pv_vg_name(pvl->pv), 
-				 correct_vg->seqno);
+			if (act)
+				log_warn("Missing device %s reappeared, updating "
+					 "metadata for VG %s to version %u.",
+					 pv_dev_name(pvl->pv),  pv_vg_name(pvl->pv), 
+					 correct_vg->seqno);
 			if (pvl->pv->pe_alloc_count == 0) {
-				pv->status &= ~MISSING_PV;
-				pvl->pv->status &= ~MISSING_PV;
-			} else
+				if (act) {
+					pv->status &= ~MISSING_PV;
+					pvl->pv->status &= ~MISSING_PV;
+				}
+				++ rv;
+			} else if (act)
 				log_warn("Device still marked missing because of allocated data "
 					 "on it, remove volumes and consider vgreduce --removemissing.");
 		}
+	return rv;
+}
+
+static int _repair_inconsistent_vg(struct volume_group *vg)
+{
+	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
+
+	vg->cmd->handles_missing_pvs = 1;
+	if (!vg_write(vg)) {
+		log_error("Automatic metadata correction failed");
+		vg->cmd->handles_missing_pvs = saved_handles_missing_pvs;
+		return 0;
+	}
+
+	vg->cmd->handles_missing_pvs = saved_handles_missing_pvs;
+
+	if (!vg_commit(vg)) {
+		log_error("Automatic metadata correction commit failed");
+		return 0;
+	}
+
+	return 1;
 }
 
 static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
@@ -2951,12 +2978,12 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_mdas = 0;
 	int inconsistent_mda_count = 0;
 	unsigned use_precommitted = precommitted;
-	unsigned saved_handles_missing_pvs = cmd->handles_missing_pvs;
 	struct dm_list *pvids;
 	struct pv_list *pvl, *pvl2;
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
 	unsigned seqno = 0;
+	int reappeared = 0;
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
@@ -2969,8 +2996,16 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	if (lvmetad_active() && !use_precommitted) {
-		*consistent = 1;
-		return lvmcache_get_vg(cmd, vgname, vgid, precommitted);
+		if ((correct_vg = lvmcache_get_vg(cmd, vgname, vgid, precommitted))) {
+			dm_list_iterate_items(pvl, &correct_vg->pvs)
+				if (pvl->pv->dev)
+					reappeared += _check_reappeared_pv(correct_vg, pvl->pv, *consistent);
+			if (reappeared && *consistent)
+				*consistent = _repair_inconsistent_vg(correct_vg);
+			else
+				*consistent = !reappeared;
+		}
+		return correct_vg;
 	}
 
 	/*
@@ -3339,22 +3374,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		 * update metadata and remove MISSING flag
 		 */
 		dm_list_iterate_items(pvl, &all_pvs)
-			check_reappeared_pv(correct_vg, pvl->pv);
+			_check_reappeared_pv(correct_vg, pvl->pv, 1);
 
-		cmd->handles_missing_pvs = 1;
-		if (!vg_write(correct_vg)) {
-			log_error("Automatic metadata correction failed");
+		if (!_repair_inconsistent_vg(correct_vg)) {
 			_free_pv_list(&all_pvs);
 			release_vg(correct_vg);
-			cmd->handles_missing_pvs = saved_handles_missing_pvs;
-			return NULL;
-		}
-		cmd->handles_missing_pvs = saved_handles_missing_pvs;
-
-		if (!vg_commit(correct_vg)) {
-			log_error("Automatic metadata correction commit "
-				  "failed");
-			release_vg(correct_vg);
 			return NULL;
 		}
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 2408c23..21ac204 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -486,7 +486,4 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
-void check_reappeared_pv(struct volume_group *correct_vg,
-			 struct physical_volume *pv);
-
 #endif


