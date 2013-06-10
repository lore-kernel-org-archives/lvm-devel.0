From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Jun 2013 20:51:02 +0000 (UTC)
Subject: master - Add and track an "ondisk" pointer to struct volume_group.
Message-ID: <20130610205102.A120D60F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d5f2306bd4635cdc7e97a6a875384a00c9be460
Commit:        5d5f2306bd4635cdc7e97a6a875384a00c9be460
Parent:        c1e851e2084cbb09ed28199bc332aa3b1e99bbae
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 17 16:27:44 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 10 17:26:29 2013 +0200

Add and track an "ondisk" pointer to struct volume_group.

This allows us to get the current on-disk version of the metadata whenever we
have the current in-flight version, without a recourse to scanning or lvmcache.
---
 lib/metadata/lv.h       |    1 +
 lib/metadata/metadata.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.c       |    1 +
 lib/metadata/vg.h       |    9 +++++++++
 4 files changed, 58 insertions(+), 0 deletions(-)

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
index 62b5c3f..6cee8d5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -831,6 +831,21 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _vg_update_vg_ondisk(struct volume_group *vg)
+{
+	struct dm_config_tree *cft;
+	if (vg->vg_ondisk) /* we already have it */
+		return 1;
+
+	cft = export_vg_to_config_tree(vg);
+	if (!cft)
+		return 0;
+
+	vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
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
 
+	if (vg->fid && !_vg_update_vg_ondisk(vg))
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
+		release_vg(vg->vg_ondisk);
+		vg->vg_ondisk = NULL;
+		if (!_vg_update_vg_ondisk(vg)) /* make a new one for future edits */
+			return_0;
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -4523,3 +4548,25 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
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
+	if (vg->vg_ondisk)
+		vg = vg->vg_ondisk;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (!strncmp(lvl->lv->lvid.s, lv->lvid.s, sizeof(lv->lvid)))
+			return lvl->lv;
+
+	log_error(INTERNAL_ERROR "LV %s/%s (UUID %s) not found in ondisk metadata.",
+		  lv->vg->name, lv->name, lv->lvid.s);
+	return NULL;
+}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index a868df7..50e8328 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -87,6 +87,7 @@ void release_vg(struct volume_group *vg)
 	    !lvmcache_vginfo_holders_dec_and_test_for_zero(vg->vginfo))
 		return;
 
+	release_vg(vg->vg_ondisk);
 	_free_vg(vg);
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index f876968..0dc3ba7 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -48,6 +48,15 @@ struct volume_group {
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
 
+	/*
+	 * The parsed on-disk copy of this VG; is NULL if this is the on-disk
+	 * version (i.e. vg_ondisk == NULL *implies* this is the on-disk copy,
+	 * there is no guarantee that if this VG is the same as the on-disk one
+	 * this will be NULL). The pointer is maintained by calls to
+	 * _vg_update_vg_ondisk.
+	 */
+	struct volume_group *vg_ondisk;
+
 	alloc_policy_t alloc;
 	uint64_t status;
 


