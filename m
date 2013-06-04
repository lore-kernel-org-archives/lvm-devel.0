From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:50 +0000 (UTC)
Subject: dev-mornfall-activate - Add and track an "ondisk" pointer to struct volume_group.
Message-ID: <20130604192850.0CA0C6105A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=448fa9732ad47bf059930f1cfbdae95be073b540
Commit:        448fa9732ad47bf059930f1cfbdae95be073b540
Parent:        140007a272f471dddb85d1014cee4a06db7266fa
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 17 16:27:44 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jun 4 18:17:15 2013 +0200

Add and track an "ondisk" pointer to struct volume_group.

This allows us to get the current on-disk version of the metadata whenever we
have the current in-flight version, without a recourse to scanning or lvmcache.
---
 lib/metadata/lv.h       |    1 +
 lib/metadata/metadata.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.c       |    1 +
 lib/metadata/vg.h       |    3 ++
 4 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 8e771a1..b1cce51 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -90,4 +90,5 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
+struct logical_volume *lv_ondisk(struct logical_volume *lv);
 #endif /* _LVM_LV_H */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 62b5c3f..47eda27 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -831,6 +831,21 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _vg_metadata_snapshot(struct volume_group *vg)
+{
+	struct dm_config_tree *cft;
+	if (vg->ondisk) /* we already have it */
+		return 1;
+
+	cft = export_vg_to_config_tree(vg);
+	if (!cft)
+		return 0;
+
+	vg->ondisk = import_vg_from_config_tree(cft, vg->fid);
+	dm_config_destroy(cft);
+	return 1;
+}
+
 /*
  * Create a (struct volume_group) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
@@ -839,6 +854,7 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
+
 	/* Never return a cached VG structure for a failure */
 	if (vg && vg->vginfo && failure != SUCCESS) {
 		release_vg(vg);
@@ -848,6 +864,9 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
+	if (vg->fid && !_vg_metadata_snapshot(vg))
+		vg->read_status |= FAILED_ALLOCATION;
+
 	if (vg->read_status != failure)
 		vg->read_status = failure;
 
@@ -2690,6 +2709,12 @@ int vg_commit(struct volume_group *vg)
 		 * The volume_group structure could be reused later.
 		 */
 		vg->old_name = NULL;
+
+		/* This *is* the original now that it's commited. */
+		release_vg(vg->ondisk);
+		vg->ondisk = NULL;
+		if (!_vg_metadata_snapshot(vg)) /* make a new one for future edits */
+			return_0;
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -4523,3 +4548,34 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
 	}
 	return dm_pool_end_object(mem);
 }
+
+struct logical_volume *lv_ondisk(struct logical_volume *lv)
+{
+	struct volume_group *vg;
+	struct lv_list *lvl;
+
+	if (!lv)
+		return NULL;
+
+	vg = lv->vg;
+
+	if (vg->ondisk)
+		vg = vg->ondisk;
+
+	/*
+	 * LVM1 snapshots are somehow broken in the ondisk copy of VG. Since
+	 * they are deprecated, we just bail here on LVM1 and take the slow
+	 * (re-read from disk or lvmetad) path.
+	 */
+	if (vg->fid && !strcmp(vg->fid->fmt->name, "lvm1"))
+		return NULL;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (!strncmp(lvl->lv->lvid.s, lv->lvid.s, sizeof(lv->lvid))) {
+			log_error("Found original of LV %p at %p", lvl->lv, lv);
+			return lvl->lv;
+		}
+
+	log_error(INTERNAL_ERROR "LV %s/%s has vanished into thin air.", lv->vg->name, lv->name);
+	return NULL;
+}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index a868df7..04c8ff0 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -87,6 +87,7 @@ void release_vg(struct volume_group *vg)
 	    !lvmcache_vginfo_holders_dec_and_test_for_zero(vg->vginfo))
 		return;
 
+	release_vg(vg->ondisk);
 	_free_vg(vg);
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index f876968..ec1728f 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -48,6 +48,9 @@ struct volume_group {
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
 
+	struct volume_group *ondisk; /* the parsed on-disk copy of this VG;
+				      * NULL if this is the on-disk version */
+
 	alloc_policy_t alloc;
 	uint64_t status;
 


