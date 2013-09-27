From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 27 Sep 2013 14:10:24 -0500
Subject: [PATCH 04/12] metadata.c: Call refactored vgreduce_single
In-Reply-To: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
References: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
Message-ID: <1380309032-12736-5-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Replace the code with the refactored vgreduce_single instead
of calling its own implementation.

Corrects bug: https://bugzilla.redhat.com/show_bug.cgi?id=989174

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |  2 +-
 lib/metadata/metadata.c          | 35 ++++++-----------------------------
 lib/metadata/vg.c                | 36 +++++++++++++++++++++---------------
 tools/vgreduce.c                 |  2 +-
 4 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9c310d4..64bd650 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -591,7 +591,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 int vg_reduce(struct volume_group *vg, const char *pv_name);
 
 int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
-			    struct physical_volume *pv);
+			    struct physical_volume *pv, int commit);
 
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1e34f83..942109d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -685,50 +685,27 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 	return 1;
 }
 
-/* FIXME: use this inside vgreduce_single? */
 int vg_reduce(struct volume_group *vg, const char *pv_name)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 
-	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
-		return 0;
-
-	if (!archive(vg))
-		goto bad;
-
-	/* remove each pv */
 	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 		log_error("Physical volume %s not in volume group %s.",
 			  pv_name, vg->name);
-		goto bad;
+		return 0;
 	}
 
 	pv = pvl->pv;
 
-	if (pv_pe_alloc_count(pv)) {
-		log_error("Physical volume %s still in use.",
-			  pv_name);
-		goto bad;
-	}
-
-	if (!dev_get_size(pv_dev(pv), &pv->size)) {
-		log_error("%s: Couldn't get size.", pv_name);
-		goto bad;
+	if (vgreduce_single(vg->cmd, vg, pv, 0)) {
+		dm_list_add(&vg->removed_pvs, &pvl->list);
+		return 1;
 	}
 
-	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
-	vg->extent_count -= pv_pe_count(pv);
-	del_pvl_from_vgs(vg, pvl);
-
-	/* add pv to the remove_pvs list */
-	dm_list_add(&vg->removed_pvs, &pvl->list);
-
-	return 1;
-
-      bad:
 	log_error("Unable to remove physical volume '%s' from "
-		  "volume group '%s'.", pv_name, vg->name);
+				"volume group '%s'.", pv_name, vg->name);
+
 	return 0;
 }
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 75fc0c1..0de0847 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -576,7 +576,7 @@ char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 }
 
 int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
-			    struct physical_volume *pv)
+			    struct physical_volume *pv, int commit)
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
@@ -637,25 +637,31 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		goto bad;
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("Removal of physical volume \"%s\" from "
-			  "\"%s\" failed", name, vg->name);
-		goto bad;
-	}
+	/*
+	 * Only write out the needed changes if so requested by caller.
+	 */
+	if (commit) {
+		if (!vg_write(vg) || !vg_commit(vg)) {
+			log_error("Removal of physical volume \"%s\" from "
+				  "\"%s\" failed", name, vg->name);
+			goto bad;
+		}
 
-	if (!pv_write(cmd, pv, 0)) {
-		log_error("Failed to clear metadata from physical "
-			  "volume \"%s\" "
-			  "after removal from \"%s\"", name, vg->name);
-		goto bad;
-	}
+		if (!pv_write(cmd, pv, 0)) {
+			log_error("Failed to clear metadata from physical "
+				  "volume \"%s\" "
+				  "after removal from \"%s\"", name, vg->name);
+			goto bad;
+		}
 
-	backup(vg);
+		backup(vg);
 
-	log_print_unless_silent("Removed \"%s\" from volume group \"%s\"", name, vg->name);
+		log_print_unless_silent("Removed \"%s\" from volume group \"%s\"",
+				name, vg->name);
+	}
 	r = 1;
 bad:
-	if (pvl)
+	if (pvl && commit)
 		free_pv_fid(pvl->pv);
 	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 534a4fb..0ade4fa 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -125,7 +125,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
 			    void *handle __attribute__((unused)))
 {
-	int r = vgreduce_single(cmd, vg, pv);
+	int r = vgreduce_single(cmd, vg, pv, 1);
 
 	if (!r)
 		return ECMD_FAILED;
-- 
1.8.2.1


