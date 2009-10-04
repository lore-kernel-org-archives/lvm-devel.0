From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:40 -0400
Subject: [PATCH 03/10] Add pvcreate_params to vg_extend.
In-Reply-To: <1254697907-16448-3-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Another refactoring for implicit pvcreate support.  We need to get
the pvcreate parameters somehow to the vg_extend routine.  Options
seemed to be:
1. Attach the parameters to struct volume_group.  I personally
did not like this idea in most cases, though one could make an
agrument why it might be ok at least for some of the parameters
(e.g. metadatacopies).
2. Pass them in to the extend routine.  This second route seemed
to be the best approach given the constraints.

Future patches will parse the command line and fill in the actual
values for the pvcreate_single call.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.c          |   15 +++++++++++++--
 liblvm/lvm_vg.c                  |    2 +-
 tools/vgcreate.c                 |    2 +-
 tools/vgextend.c                 |    2 +-
 5 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bf830aa..ebaea92 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -453,7 +453,8 @@ int vg_remove_check(struct volume_group *vg);
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, char *pv_name);
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b6f84d7..5f65d26 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -582,7 +582,18 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 	return 1;
 }
 
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
+/*
+ * Extend a VG by a single PV / device path
+ *
+ * Parameters:
+ * - vg: handle of volume group to extend by 'pv_name'
+ * - pv_count: count of device paths of PVs
+ * - pv_names: device paths of PVs to add to VG
+ * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
+ *
+ */
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+	      struct pvcreate_params *pp)
 {
 	int i;
 
@@ -591,7 +602,7 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!vg_extend_single_pv(vg, pv_names[i], NULL))
+		if (!vg_extend_single_pv(vg, pv_names[i], pp))
 			goto bad;
 	}
 
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a0a7b1f..0c097c0 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -60,7 +60,7 @@ int lvm_vg_extend(vg_t vg, const char *device)
 		return -1;
 	}
 
-	if (!vg_extend(vg, 1, (char **) &device)) {
+	if (!vg_extend(vg, 1, (char **) &device, NULL)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 2100877..d171026 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -63,7 +63,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc - 1, argv + 1))
+	if (!vg_extend(vg, argc - 1, argv + 1, NULL))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
diff --git a/tools/vgextend.c b/tools/vgextend.c
index b659492..9fa7d31 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -54,7 +54,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		goto_bad;
 
 	/* extend vg */
-	if (!vg_extend(vg, argc, argv))
+	if (!vg_extend(vg, argc, argv, NULL))
 		goto_bad;
 
 	/* ret > 0 */
-- 
1.6.0.6


