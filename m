From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:10 +0000 (UTC)
Subject: master - refactor: rename struct pv_to_create --> struct pv_to_write
Message-ID: <20160215120810.BA90D60C21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4361543f3eb037237438c32f1c8a558f4d695e93
Commit:        4361543f3eb037237438c32f1c8a558f4d695e93
Parent:        952498ef4d1d9aada0f81ba367d870c7aa1a0413
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 9 12:29:30 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:45 2016 +0100

refactor: rename struct pv_to_create --> struct pv_to_write

We'll use this struct in subsequent patches for PVs which should
be rewritten, not just created. So rename struct pv_to_create to
struct pv_to_write for clarity.
---
 lib/metadata/metadata.c |   36 ++++++++++++++++++------------------
 lib/metadata/vg.c       |    2 +-
 lib/metadata/vg.h       |    4 ++--
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d8a7128..0ca17f6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -179,7 +179,7 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv, struct pvcreate_params *pp)
 {
-	struct pv_to_create *pvc;
+	struct pv_to_write *pvw;
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
@@ -279,13 +279,13 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		}
 
 	if (pv->status & UNLABELLED_PV) {
-		if (!(pvc = dm_pool_zalloc(mem, sizeof(*pvc)))) {
-			log_error("pv_to_create allocation for '%s' failed", pv_name);
+		if (!(pvw = dm_pool_zalloc(mem, sizeof(*pvw)))) {
+			log_error("pv_to_write allocation for '%s' failed", pv_name);
 			return 0;
 		}
-		pvc->pv = pv;
-		pvc->pp = pp;
-		dm_list_add(&vg->pvs_to_create, &pvc->list);
+		pvw->pv = pv;
+		pvw->pp = pp;
+		dm_list_add(&vg->pvs_to_write, &pvw->list);
 	}
 
 	return 1;
@@ -1608,10 +1608,10 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 }
 
 
-static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_create *pvc)
+static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 {
-	int zero = pvc->pp->zero;
-	struct physical_volume *pv = pvc->pv;
+	int zero = pvw->pp->zero;
+	struct physical_volume *pv = pvw->pv;
 	struct device *dev = pv->dev;
 	const char *pv_name = dev_name(dev);
 
@@ -1762,10 +1762,10 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 
 	pv->status |= UNLABELLED_PV;
 	if (write_now) {
-		struct pv_to_create pvc;
-		pvc.pp = pp;
-		pvc.pv = pv;
-		if (!_pvcreate_write(cmd, &pvc))
+		struct pv_to_write pvw;
+		pvw.pp = pp;
+		pvw.pv = pv;
+		if (!_pvcreate_write(cmd, &pvw))
 			goto bad;
 	}
 
@@ -3047,7 +3047,7 @@ out:
 int vg_write(struct volume_group *vg)
 {
 	struct dm_list *mdah;
-	struct pv_to_create *pv_to_create, *pv_to_create_safe;
+        struct pv_to_write *pv_to_write, *pv_to_write_safe;
 	struct metadata_area *mda;
 	struct lv_list *lvl;
 	int revert = 0, wrote = 0;
@@ -3103,10 +3103,10 @@ int vg_write(struct volume_group *vg)
 	memlock_unlock(vg->cmd);
 	vg->seqno++;
 
-	dm_list_iterate_items_safe(pv_to_create, pv_to_create_safe, &vg->pvs_to_create) {
-		if (!_pvcreate_write(vg->cmd, pv_to_create))
-			return 0;
-		dm_list_del(&pv_to_create->list);
+        dm_list_iterate_items_safe(pv_to_write, pv_to_write_safe, &vg->pvs_to_write) {
+		if (!_pvcreate_write(vg->cmd, pv_to_write))
+			return_0;
+		dm_list_del(&pv_to_write->list);
 	}
 
 	/* Write to each copy of the metadata area */
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 59af13e..e93108c 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -60,7 +60,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	}
 
 	dm_list_init(&vg->pvs);
-	dm_list_init(&vg->pvs_to_create);
+	dm_list_init(&vg->pvs_to_write);
 	dm_list_init(&vg->pvs_outdated);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 6ff77cf..1c7c31c 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -32,7 +32,7 @@ typedef enum {
 	ALLOC_INHERIT
 } alloc_policy_t;
 
-struct pv_to_create {
+struct pv_to_write {
 	struct dm_list list;
 	struct physical_volume *pv;
 	struct pvcreate_params *pp;
@@ -90,7 +90,7 @@ struct volume_group {
 	 * a PV label yet. They need to be pvcreate'd at vg_write time.
 	 */
 
-	struct dm_list pvs_to_create;
+	struct dm_list pvs_to_write;
 
 	/*
 	 * List of physical volumes that carry outdated metadata that belongs


