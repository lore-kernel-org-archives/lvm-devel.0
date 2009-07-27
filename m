From: Thomas Woerner <twoerner@redhat.com>
Date: Mon, 27 Jul 2009 15:12:35 +0200
Subject: [PATCH 1/3] Add vg_reduce to metadata.c and metadata-exported.h
In-Reply-To: <1248700357-10112-1-git-send-email-twoerner@redhat.com>
References: <1248700357-10112-1-git-send-email-twoerner@redhat.com>
Message-ID: <1248700357-10112-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This function behaves a little bit different than vg_reduce_single, because
it allowes to remove even the latest pv. This has been done to be consistent
to lvm_vg_create, which creates an empty vg.

removed_pvs has been added to the volume_group struct. vg_reduce adds removed
pvs to this list to be able to commit the changes for the pvs in lvm_vg_commit
in liblvm2app.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 lib/metadata/metadata-exported.h |    7 ++++
 lib/metadata/metadata.c          |   61 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 142381b..bc946da 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -243,6 +243,12 @@ struct volume_group {
 	 */
 
 	/*
+	 * List of removed physical volumes by pvreduce.
+	 * They have to get cleared on vg_commit.
+	 */
+	struct dm_list removed_pvs;
+
+	/*
 	 * Store result of the last vg_read().
 	 * 0 for success else appropriate FAILURE_* bits set.
 	 */
@@ -437,6 +443,7 @@ int vg_remove_single(vg_t *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
+int vg_reduce(struct volume_group *vg, char *pv_name);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 838add8..fb6f91b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -532,6 +532,63 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 	return 0;
 }
 
+int vg_reduce(struct volume_group *vg, char *pv_name)
+{
+	struct physical_volume *pv;
+	struct cmd_context *cmd = vg->cmd;
+	struct pv_list *pvl;
+
+	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
+		return 0;
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	if (!archive(vg))
+		goto bad;
+
+	/* remove each pv */
+	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+		log_error("Physical volume %s not in volume group %s.",
+			  pv_name, vg->name);
+		goto bad;
+	}
+
+	pv = pvl->pv;
+
+	if (pv_pe_alloc_count(pv)) {
+		log_error("Physical volume %s still in use.",
+			  pv_name);
+		goto bad;
+	}
+
+	if (!dev_get_size(pv_dev(pv), &pv->size)) {
+		log_error("%s: Couldn't get size.", pv_name);
+		goto bad;
+	}
+
+	vg->pv_count--;
+	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
+	vg->extent_count -= pv_pe_count(pv);
+
+	/* add pv to the remove_pvs list */
+	dm_list_del(&pvl->list);
+	dm_list_add(&vg->removed_pvs, &pvl->list);
+
+	unlock_vg(cmd, VG_ORPHANS);
+	return 1;
+
+      bad:
+	log_error("Unable to add physical volume '%s' to "
+		  "volume group '%s'.", pv_name, vg->name);
+	unlock_vg(cmd, VG_ORPHANS);
+	if (pvl)
+		dm_list_del(&pvl->list);
+	return 0;
+}
+
 const char *strip_dir(const char *vg_name, const char *dev_dir)
 {
 	size_t len = strlen(dev_dir);
@@ -660,6 +717,9 @@ vg_t *vg_create(struct cmd_context *cmd, const char *vg_name)
 
 	dm_list_init(&vg->tags);
 
+	/* initialize removed_pvs list */
+	dm_list_init(&vg->removed_pvs);
+
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
 						       NULL, NULL))) {
 		log_error("Failed to create format instance");
@@ -2165,6 +2225,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
 	vg->vgmem = mem;
 	vg->cmd = cmd;
 	if (!(vg->name = dm_pool_strdup(mem, orphan_vgname))) {
-- 
1.6.2.5


