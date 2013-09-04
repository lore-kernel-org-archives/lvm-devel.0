From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  4 Sep 2013 15:07:05 -0500
Subject: [PATCH 4/4] metadata.c: Call refactored vgreduce_single
In-Reply-To: <1378325225-16335-1-git-send-email-tasleson@redhat.com>
References: <1378325225-16335-1-git-send-email-tasleson@redhat.com>
Message-ID: <1378325225-16335-4-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Replace the code with the refactored vgreduce_single instead
of calling its own implementation.

NOTE: This change although it works is incomplete because
in the case where we return an error "Cannot remove final
metadata area on ..." the vg pointer that was passed in is
modified significantly and thus cannot be used again by the
caller.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.c | 35 ++---------------------------------
 lib/metadata/vg.c       |  6 ++++++
 2 files changed, 8 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4ae7726..fed29da 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -685,51 +685,20 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
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
-	}
-
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
-	log_error("Unable to remove physical volume '%s' from "
-		  "volume group '%s'.", pv_name, vg->name);
-	return 0;
+	return vgreduce_single(vg->cmd, vg, pv);
 }
 
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 54e3c42..e5a21eb 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -642,6 +642,12 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	if (vg_read_error(orphan_vg))
 		goto bad;
 
+	/*
+	 *  FIXME: The vg has been modified up to this point and will get modified
+	 *  further in the call to vg_split_mdas.  When we hit this error we leave
+	 *  the vg pointer in this inconsistent state which is a problem when the
+	 *  user is a lvm2app library user.
+	 */
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
 		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
 			  name, vg->name);
-- 
1.8.2.1


