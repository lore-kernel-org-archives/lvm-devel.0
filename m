From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:24 +0000 (UTC)
Subject: master - vg_write: add list of pvs to write
Message-ID: <20160225151524.CDD3C60CB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e5ad77f5f89bdc8a054d962a89e450900b249e7
Commit:        5e5ad77f5f89bdc8a054d962a89e450900b249e7
Parent:        3ac860334b4502fca2f0c780ee968bd62733a73e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 12:43:24 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

vg_write: add list of pvs to write

The vg->pv_write_list contains pv_list structs for which
vg_write() should call pv_write().

The new list will replace vg->pvs_to_write that contains
vg_to_create structs which are used to perform higher-level
pvcreate-related operations. The higher level pvcreate
operations will be moved out of vg_write() to higher levels.
---
 lib/metadata/metadata.c |    9 ++++++++-
 lib/metadata/vg.c       |    1 +
 lib/metadata/vg.h       |    4 +++-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a41c227..d3d4cab 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3146,7 +3146,8 @@ static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 int vg_write(struct volume_group *vg)
 {
 	struct dm_list *mdah;
-        struct pv_to_write *pv_to_write, *pv_to_write_safe;
+	struct pv_to_write *pv_to_write, *pv_to_write_safe;
+	struct pv_list *pvl, *pvl_safe;
 	struct metadata_area *mda;
 	struct lv_list *lvl;
 	int revert = 0, wrote = 0;
@@ -3207,6 +3208,12 @@ int vg_write(struct volume_group *vg)
 	memlock_unlock(vg->cmd);
 	vg->seqno++;
 
+	dm_list_iterate_items_safe(pvl, pvl_safe, &vg->pv_write_list) {
+		if (!pv_write(vg->cmd, pvl->pv, 1))
+			return_0;
+		dm_list_del(&pvl->list);
+	}
+
         dm_list_iterate_items_safe(pv_to_write, pv_to_write_safe, &vg->pvs_to_write) {
 		if (!_pvcreate_write(vg->cmd, pv_to_write))
 			return_0;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index e93108c..1456fbb 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -61,6 +61,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->pvs_to_write);
+	dm_list_init(&vg->pv_write_list);
 	dm_list_init(&vg->pvs_outdated);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index f6c7bcc..f41def8 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -91,7 +91,9 @@ struct volume_group {
 	 * a PV label yet. They need to be pvcreate'd at vg_write time.
 	 */
 
-	struct dm_list pvs_to_write;
+	struct dm_list pvs_to_write; /* struct pv_to_write */
+
+	struct dm_list pv_write_list; /* struct pv_list */
 
 	/*
 	 * List of physical volumes that carry outdated metadata that belongs


