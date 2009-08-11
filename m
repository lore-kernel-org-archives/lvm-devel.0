From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 Aug 2009 10:00:59 -0400
Subject: [PATCH 2/3] Make lvm2app lv_t handle definition consistent with lvm_t.
In-Reply-To: <1249999260-14593-2-git-send-email-dwysocha@redhat.com>
References: <1249999260-14593-1-git-send-email-dwysocha@redhat.com>
	<1249999260-14593-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1249999260-14593-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch update lv_t handle to be consistent with lvm_t - define as a pointer
to internal struct logical_volume.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   24 ++++++++++++------------
 liblvm/lvm_lv.c  |   22 +++++++++++-----------
 test/api/test.c  |   12 ++++++------
 3 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 52616f0..0d45a29 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -121,7 +121,7 @@ typedef struct volume_group *vg_t;
  * group.  Changes will be written to disk when the volume group gets
  * committed to disk.
  */
-typedef struct logical_volume lv_t;
+typedef struct logical_volume *lv_t;
 
 /**
  * Physical volume object.
@@ -139,7 +139,7 @@ typedef struct physical_volume pv_t;
  */
 typedef struct lvm_lv_list {
 	struct dm_list list;
-	lv_t *lv;
+	lv_t lv;
 } lv_list_t;
 
 /**
@@ -623,7 +623,7 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg);
  * non-NULL handle to an LV object created, or NULL if creation fails.
  *
  */
-lv_t *lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
+lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 
 /**
  * Activate a logical volume.
@@ -639,7 +639,7 @@ lv_t *lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_lv_activate(lv_t *lv);
+int lvm_lv_activate(lv_t lv);
 
 /**
  * Deactivate a logical volume.
@@ -652,7 +652,7 @@ int lvm_lv_activate(lv_t *lv);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_lv_deactivate(lv_t *lv);
+int lvm_lv_deactivate(lv_t lv);
 
 /**
  * Remove a logical volume from a volume group.
@@ -669,7 +669,7 @@ int lvm_lv_deactivate(lv_t *lv);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_remove_lv(lv_t *lv);
+int lvm_vg_remove_lv(lv_t lv);
 
 /**
  * Get the current name of a logical volume.
@@ -683,7 +683,7 @@ int lvm_vg_remove_lv(lv_t *lv);
  * \return
  * Copy of the uuid string.
  */
-char *lvm_lv_get_uuid(const lv_t *lv);
+char *lvm_lv_get_uuid(const lv_t lv);
 
 /**
  * Get the current uuid of a logical volume.
@@ -697,7 +697,7 @@ char *lvm_lv_get_uuid(const lv_t *lv);
  * \return
  * Copy of the name.
  */
-char *lvm_lv_get_name(const lv_t *lv);
+char *lvm_lv_get_name(const lv_t lv);
 
 /**
  * Get the current size in bytes of a logical volume.
@@ -708,7 +708,7 @@ char *lvm_lv_get_name(const lv_t *lv);
  * \return
  * Size in bytes.
  */
-uint64_t lvm_lv_get_size(const lv_t *lv);
+uint64_t lvm_lv_get_size(const lv_t lv);
 
 /**
  * Get the current activation state of a logical volume.
@@ -719,7 +719,7 @@ uint64_t lvm_lv_get_size(const lv_t *lv);
  * \return
  * 1 if the LV is active in the kernel, 0 if not
  */
-uint64_t lvm_lv_is_active(const lv_t *lv);
+uint64_t lvm_lv_is_active(const lv_t lv);
 
 /**
  * Get the current suspended state of a logical volume.
@@ -730,7 +730,7 @@ uint64_t lvm_lv_is_active(const lv_t *lv);
  * \return
  * 1 if the LV is suspended in the kernel, 0 if not
  */
-uint64_t lvm_lv_is_suspended(const lv_t *lv);
+uint64_t lvm_lv_is_suspended(const lv_t lv);
 
 /**
  * Resize logical volume to new_size bytes.
@@ -747,7 +747,7 @@ uint64_t lvm_lv_is_suspended(const lv_t *lv);
  * 0 (success) or -1 (failure).
  *
  */
-int lvm_lv_resize(const lv_t *lv, uint64_t new_size);
+int lvm_lv_resize(const lv_t lv, uint64_t new_size);
 
 /************************** physical volume handling ************************/
 
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 86e169d..d28e6bd 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -24,12 +24,12 @@
 #include <string.h>
 
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
-uint64_t lvm_lv_get_size(const lv_t *lv)
+uint64_t lvm_lv_get_size(const lv_t lv)
 {
 	return lv_size(lv);
 }
 
-char *lvm_lv_get_uuid(const lv_t *lv)
+char *lvm_lv_get_uuid(const lv_t lv)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -40,7 +40,7 @@ char *lvm_lv_get_uuid(const lv_t *lv)
 	return strndup((const char *)uuid, 64);
 }
 
-char *lvm_lv_get_name(const lv_t *lv)
+char *lvm_lv_get_name(const lv_t lv)
 {
 	char *name;
 
@@ -50,7 +50,7 @@ char *lvm_lv_get_name(const lv_t *lv)
 	return name;
 }
 
-uint64_t lvm_lv_is_active(const lv_t *lv)
+uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
 	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
@@ -59,7 +59,7 @@ uint64_t lvm_lv_is_active(const lv_t *lv)
 	return 0;
 }
 
-uint64_t lvm_lv_is_suspended(const lv_t *lv)
+uint64_t lvm_lv_is_suspended(const lv_t lv)
 {
 	struct lvinfo info;
 	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
@@ -101,7 +101,7 @@ static void _lv_set_default_linear_params(struct cmd_context *cmd,
  * lvm_vg_write.  However, this appears to be non-trivial change until
  * lv_create_single is refactored by segtype.
  */
-lv_t *lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
+lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 {
 	struct lvcreate_params lp;
 	uint64_t extents;
@@ -120,14 +120,14 @@ lv_t *lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 	lvl = find_lv_in_vg(vg, name);
 	if (!lvl)
 		return NULL;
-	return (lv_t *) lvl->lv;
+	return (lv_t) lvl->lv;
 }
 
 /*
  * FIXME: This function should probably not commit to disk but require calling
  * lvm_vg_write.
  */
-int lvm_vg_remove_lv(lv_t *lv)
+int lvm_vg_remove_lv(lv_t lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
 		return -1;
@@ -138,7 +138,7 @@ int lvm_vg_remove_lv(lv_t *lv)
 	return 0;
 }
 
-int lvm_lv_activate(lv_t *lv)
+int lvm_lv_activate(lv_t lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
 		return -1;
@@ -173,7 +173,7 @@ int lvm_lv_activate(lv_t *lv)
 	return 0;
 }
 
-int lvm_lv_deactivate(lv_t *lv)
+int lvm_lv_deactivate(lv_t lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
 		return -1;
@@ -186,7 +186,7 @@ int lvm_lv_deactivate(lv_t *lv)
 	return 0;
 }
 
-int lvm_lv_resize(const lv_t *lv, uint64_t new_size)
+int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
 	log_error("NOT IMPLEMENTED YET");
diff --git a/test/api/test.c b/test/api/test.c
index 65bc292..308c867 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -136,9 +136,9 @@ static int _hash_create(void)
 }
 
 /* FIXME: this should be per vg */
-static lv_t *_lookup_lv_by_name(const char *name)
+static lv_t _lookup_lv_by_name(const char *name)
 {
-	lv_t *lv;
+	lv_t lv;
 
 	if (!name) {
 		printf ("Invalid LV name\n");
@@ -516,7 +516,7 @@ static void _lvs_in_vg(char **argv, int argc)
 
 static void _lv_deactivate(char **argv, int argc)
 {
-	lv_t *lv;
+	lv_t lv;
 	int rc=0;
 
 	if (argc < 3) {
@@ -532,7 +532,7 @@ static void _lv_deactivate(char **argv, int argc)
 }
 static void _lv_activate(char **argv, int argc)
 {
-	lv_t *lv;
+	lv_t lv;
 	int rc=0;
 
 	if (argc < 3) {
@@ -548,7 +548,7 @@ static void _lv_activate(char **argv, int argc)
 }
 static void _vg_remove_lv(char **argv, int argc)
 {
-	lv_t *lv;
+	lv_t lv;
 
 	if (argc < 3) {
 		printf("Please enter vgname, lvname\n");
@@ -569,7 +569,7 @@ static void _vg_remove_lv(char **argv, int argc)
 static void _vg_create_lv_linear(char **argv, int argc)
 {
 	vg_t vg;
-	lv_t *lv;
+	lv_t lv;
 
 	if (argc < 4) {
 		printf("Please enter vgname, lvname, and size\n");
-- 
1.6.0.6


