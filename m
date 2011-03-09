From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:37 +0100
Subject: [PATCH 5/7] Call destroy_instance for all PVs in a VG while calling free_vg.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-6-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This destroys/decrements ref_count for all PVs found in the vg->pvs or
vg->removed_pvs list.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/metadata/metadata.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5e9d13a..3a72c96 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3254,9 +3254,24 @@ void free_pv_fid(struct physical_volume *pv)
 
 void free_vg(struct volume_group *vg)
 {
+	struct pv_list *pvl;
+
 	if (!vg)
 		return;
 
+	if (vg->pvs.n)
+		dm_list_iterate_items(pvl, &vg->pvs)
+			if (pvl)
+				pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
+
+	if (vg->removed_pvs.n)
+		dm_list_iterate_items(pvl, &vg->removed_pvs)
+			if (pvl)
+				pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
+
+	if (vg->fid)
+		vg->fid->fmt->ops->destroy_instance(vg->fid);
+
 	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
 		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
 			  vg->name);
-- 
1.7.4


