From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:29 +0000 (UTC)
Subject: master - metadata: use pv_write_list for _check_old_pv_ext_for_vg
Message-ID: <20160225151529.0B05860CB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5dd615c41ee1c6c77a927b5f39bf1554caaa572f
Commit:        5dd615c41ee1c6c77a927b5f39bf1554caaa572f
Parent:        bafbc72c8c42f2e48b332c54ce00403c95dc74f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 13:02:00 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

metadata: use pv_write_list for _check_old_pv_ext_for_vg

The _check_old_pv_ext_for_vg() function only needs to
do pv_write(), so it can use the simpler pv_list structs
on the pv_write_list.
---
 lib/metadata/metadata.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a5ee865..d7a9d81 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3084,12 +3084,12 @@ out:
 	return r;
 }
 
-static int _pv_in_pvs_to_write_list(struct physical_volume *pv, struct volume_group *vg)
+static int _pv_in_pv_list(struct physical_volume *pv, struct dm_list *head)
 {
-	struct pv_to_write *pvw;
+	struct pv_list *pvl;
 
-	dm_list_iterate_items(pvw, &vg->pvs_to_write) {
-		if (pvw->pv == pv)
+	dm_list_iterate_items(pvl, head) {
+		if (pvl->pv == pv)
 			return 1;
 	}
 
@@ -3102,8 +3102,7 @@ static int _pv_in_pvs_to_write_list(struct physical_volume *pv, struct volume_gr
  */
 static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 {
-	struct pv_list *pvl;
-	struct pv_to_write *pvw;
+	struct pv_list *pvl, *new_pvl;
 	int pv_needs_rewrite;
 
 	if (!(vg->fid->fmt->features & FMT_PV_FLAGS))
@@ -3122,15 +3121,15 @@ static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 			/*
 			 * Schedule PV for writing only once!
 			 */
-			if (_pv_in_pvs_to_write_list(pvl->pv, vg))
+			if (_pv_in_pv_list(pvl->pv, &vg->pv_write_list))
 				continue;
 
-			if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
+			if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl)))) {
 				log_error("pv_to_write allocation for '%s' failed", pv_dev_name(pvl->pv));
 				return 0;
 			}
-			pvw->pv = pvl->pv;
-			dm_list_add(&vg->pvs_to_write, &pvw->list);
+			new_pvl->pv = pvl->pv;
+			dm_list_add(&vg->pv_write_list, &new_pvl->list);
 		}
 	}
 


