From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:26 +0000 (UTC)
Subject: master - metadata: refactor part of add_pv_to_vg
Message-ID: <20160225151526.E403460CB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bafbc72c8c42f2e48b332c54ce00403c95dc74f8
Commit:        bafbc72c8c42f2e48b332c54ce00403c95dc74f8
Parent:        5e5ad77f5f89bdc8a054d962a89e450900b249e7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 12:49:57 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

metadata: refactor part of add_pv_to_vg

This shifts the use of the 'pv_to_write' struct
and the 'pvcreate_params' struct to the one
caller of add_pv_to_vg, which is made static.
---
 lib/metadata/metadata.c |   34 ++++++++++++++++------------------
 lib/metadata/metadata.h |    4 ----
 2 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d3d4cab..a5ee865 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -169,18 +169,15 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
  * @vg - volume group to add to
  * @pv_name - name of the pv (to be removed)
  * @pv - physical volume to add to volume group
- * @pp - physical volume creation params (OPTIONAL)
  *
  * Returns:
  *  0 - failure
  *  1 - success
  * FIXME: remove pv_name - obtain safely from pv
  */
-int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		 struct physical_volume *pv, struct pvcreate_params *pp,
-		 int new_pv)
+static int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
+		        struct physical_volume *pv, int new_pv)
 {
-	struct pv_to_write *pvw;
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
@@ -289,18 +286,6 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 			break;
 		}
 
-	if ((pv->fmt->features & FMT_PV_FLAGS) ||
-	    (pv->status & UNLABELLED_PV)) {
-		if (!(pvw = dm_pool_zalloc(mem, sizeof(*pvw)))) {
-			log_error("pv_to_write allocation for '%s' failed", pv_name);
-			return 0;
-		}
-		pvw->pv = pv;
-		pvw->pp = new_pv ? pp : NULL;
-		pvw->new_pv = new_pv;
-		dm_list_add(&vg->pvs_to_write, &pvw->list);
-	}
-
 	return 1;
 }
 
@@ -723,6 +708,7 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 			       unsigned int *max_phys_block_size)
 {
 	struct physical_volume *pv;
+	struct pv_to_write *pvw;
 	int new_pv = 0;
 
 	pv = find_pv_by_name(vg->cmd, pv_name, 1, 1);
@@ -741,9 +727,21 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 					  max_phys_block_size)))
 		goto_bad;
 
-	if (!add_pv_to_vg(vg, pv_name, pv, pp, new_pv))
+	if (!add_pv_to_vg(vg, pv_name, pv, new_pv))
 		goto_bad;
 
+	if ((pv->fmt->features & FMT_PV_FLAGS) ||
+	    (pv->status & UNLABELLED_PV)) {
+		if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
+			log_error("pv_to_write allocation for '%s' failed", pv_name);
+			return 0;
+		}
+		pvw->pv = pv;
+		pvw->pp = new_pv ? pp : NULL;
+		pvw->new_pv = new_pv;
+		dm_list_add(&vg->pvs_to_write, &pvw->list);
+	}
+
 	return 1;
 bad:
 	free_pv_fid(pv);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f2b62e4..192f88e 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -504,10 +504,6 @@ struct id pv_id(const struct physical_volume *pv);
 const struct format_type *pv_format_type(const struct physical_volume *pv);
 struct id pv_vgid(const struct physical_volume *pv);
 
-int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		 struct physical_volume *pv, struct pvcreate_params *pp,
-		 int new_pv);
-
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
 


