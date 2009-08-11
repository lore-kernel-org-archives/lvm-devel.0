From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 Aug 2009 10:00:58 -0400
Subject: [PATCH 1/3] Make lvm2app vg_t handle definition consistent with lvm_t.
In-Reply-To: <1249999260-14593-1-git-send-email-dwysocha@redhat.com>
References: <1249999260-14593-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1249999260-14593-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch update vg_t handle to be consistent with lvm_t - define as a pointer
to internal struct volume_group.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h  |   44 ++++++++++++++++++++++----------------------
 liblvm/lvm_lv.c   |    4 ++--
 liblvm/lvm_vg.c   |   46 +++++++++++++++++++++++-----------------------
 test/api/test.c   |   30 +++++++++++++++---------------
 test/api/vgtest.c |    2 +-
 5 files changed, 63 insertions(+), 63 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 5f82707..52616f0 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -112,7 +112,7 @@ typedef struct lvm *lvm_t;
  * return a read-write object, but open functions have the argument mode to
  * define if the object can be modified or not.
  */
-typedef struct volume_group vg_t;
+typedef struct volume_group *vg_t;
 
 /**
  * Logical Volume object.
@@ -285,7 +285,7 @@ int lvm_scan(lvm_t libh);
  * begin with a "#" and should be filtered out and not used.
  *
  * To process the list, use the dm_list iterator functions.  For example:
- *      vg_t *vg;
+ *      vg_t vg;
  *      struct dm_list *vgnames;
  *      struct lvm_str_list *strl;
  *
@@ -350,7 +350,7 @@ struct dm_list *lvm_list_vg_uuids(lvm_t libh);
  *
  * \return  non-NULL VG handle (success) or NULL (failure).
  */
-vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		  uint32_t flags);
 
 /**
@@ -374,7 +374,7 @@ vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
  * \return
  * non-NULL vg handle (success) or NULL (failure)
  */
-vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
+vg_t lvm_vg_create(lvm_t libh, const char *vg_name);
 
  /**
  * Write a VG to disk.
@@ -389,7 +389,7 @@ vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_write(vg_t *vg);
+int lvm_vg_write(vg_t vg);
 
 /**
  * Remove a VG from the system.
@@ -403,7 +403,7 @@ int lvm_vg_write(vg_t *vg);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_remove(vg_t *vg);
+int lvm_vg_remove(vg_t vg);
 
 /**
  * Close a VG opened with lvm_vg_create or lvm_vg_open.
@@ -417,7 +417,7 @@ int lvm_vg_remove(vg_t *vg);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_close(vg_t *vg);
+int lvm_vg_close(vg_t vg);
 
 /**
  * Extend a VG by adding a device.
@@ -440,7 +440,7 @@ int lvm_vg_close(vg_t *vg);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_extend(vg_t *vg, const char *device);
+int lvm_vg_extend(vg_t vg, const char *device);
 
 /**
  * Reduce a VG by removing an unused device.
@@ -459,7 +459,7 @@ int lvm_vg_extend(vg_t *vg, const char *device);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_reduce(vg_t *vg, const char *device);
+int lvm_vg_reduce(vg_t vg, const char *device);
 
 /**
  * Set the extent size of a VG.
@@ -478,7 +478,7 @@ int lvm_vg_reduce(vg_t *vg, const char *device);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
+int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size);
 
 /**
  * Get the current metadata sequence number of a volume group.
@@ -493,7 +493,7 @@ int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
  * \return
  * Metadata sequence number.
  */
-uint64_t lvm_vg_get_seqno(const vg_t *vg);
+uint64_t lvm_vg_get_seqno(const vg_t vg);
 
 /**
  * Get the current name of a volume group.
@@ -507,7 +507,7 @@ uint64_t lvm_vg_get_seqno(const vg_t *vg);
  * \return
  * Copy of the uuid string.
  */
-char *lvm_vg_get_uuid(const vg_t *vg);
+char *lvm_vg_get_uuid(const vg_t vg);
 
 /**
  * Get the current uuid of a volume group.
@@ -521,7 +521,7 @@ char *lvm_vg_get_uuid(const vg_t *vg);
  * \return
  * Copy of the name.
  */
-char *lvm_vg_get_name(const vg_t *vg);
+char *lvm_vg_get_name(const vg_t vg);
 
 /**
  * Get the current size in bytes of a volume group.
@@ -532,7 +532,7 @@ char *lvm_vg_get_name(const vg_t *vg);
  * \return
  * Size in bytes.
  */
-uint64_t lvm_vg_get_size(const vg_t *vg);
+uint64_t lvm_vg_get_size(const vg_t vg);
 
 /**
  * Get the current unallocated space in bytes of a volume group.
@@ -543,7 +543,7 @@ uint64_t lvm_vg_get_size(const vg_t *vg);
  * \return
  * Free size in bytes.
  */
-uint64_t lvm_vg_get_free_size(const vg_t *vg);
+uint64_t lvm_vg_get_free_size(const vg_t vg);
 
 /**
  * Get the current extent size in bytes of a volume group.
@@ -554,7 +554,7 @@ uint64_t lvm_vg_get_free_size(const vg_t *vg);
  * \return
  * Extent size in bytes.
  */
-uint64_t lvm_vg_get_extent_size(const vg_t *vg);
+uint64_t lvm_vg_get_extent_size(const vg_t vg);
 
 /**
  * Get the current number of total extents of a volume group.
@@ -565,7 +565,7 @@ uint64_t lvm_vg_get_extent_size(const vg_t *vg);
  * \return
  * Extent count.
  */
-uint64_t lvm_vg_get_extent_count(const vg_t *vg);
+uint64_t lvm_vg_get_extent_count(const vg_t vg);
 
 /**
  * Get the current number of free extents of a volume group.
@@ -576,7 +576,7 @@ uint64_t lvm_vg_get_extent_count(const vg_t *vg);
  * \return
  * Free extent count.
  */
-uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
+uint64_t lvm_vg_get_free_extent_count(const vg_t vg);
 
 /**
  * Get the current number of physical volumes of a volume group.
@@ -587,7 +587,7 @@ uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
  * \return
  * Physical volume count.
  */
-uint64_t lvm_vg_get_pv_count(const vg_t *vg);
+uint64_t lvm_vg_get_pv_count(const vg_t vg);
 
 /************************** logical volume handling *************************/
 
@@ -601,7 +601,7 @@ uint64_t lvm_vg_get_pv_count(const vg_t *vg);
  * A list of lv_list_t structures containing lv handles for this vg.
  * If no LVs exist on the given VG, NULL is returned.
  */
-struct dm_list *lvm_vg_list_lvs(vg_t *vg);
+struct dm_list *lvm_vg_list_lvs(vg_t vg);
 
 /**
  * Create a linear logical volume.
@@ -623,7 +623,7 @@ struct dm_list *lvm_vg_list_lvs(vg_t *vg);
  * non-NULL handle to an LV object created, or NULL if creation fails.
  *
  */
-lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
+lv_t *lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 
 /**
  * Activate a logical volume.
@@ -767,7 +767,7 @@ int lvm_lv_resize(const lv_t *lv, uint64_t new_size);
  * A list of pv_list_t structures containing pv handles for this vg.
  * If no PVs exist on the given VG, NULL is returned.
  */
-struct dm_list *lvm_vg_list_pvs(vg_t *vg);
+struct dm_list *lvm_vg_list_pvs(vg_t vg);
 
 /**
  * Get the current uuid of a logical volume.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index b06546e..86e169d 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -70,7 +70,7 @@ uint64_t lvm_lv_is_suspended(const lv_t *lv)
 
 /* Set defaults for non-segment specific LV parameters */
 static void _lv_set_default_params(struct lvcreate_params *lp,
-				   vg_t *vg, const char *lvname,
+				   vg_t vg, const char *lvname,
 				   uint64_t extents)
 {
 	lp->zero = 1;
@@ -101,7 +101,7 @@ static void _lv_set_default_linear_params(struct cmd_context *cmd,
  * lvm_vg_write.  However, this appears to be non-trivial change until
  * lv_create_single is refactored by segtype.
  */
-lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size)
+lv_t *lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 {
 	struct lvcreate_params lp;
 	uint64_t extents;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 51642cb..e63c60e 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -25,9 +25,9 @@
 #include <errno.h>
 #include <string.h>
 
-vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
+vg_t lvm_vg_create(lvm_t libh, const char *vg_name)
 {
-	vg_t *vg;
+	struct volume_group *vg;
 
 	vg = vg_create((struct cmd_context *)libh, vg_name);
 	/* FIXME: error handling is still TBD */
@@ -36,10 +36,10 @@ vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 		return NULL;
 	}
 	vg->open_mode = 'w';
-	return (vg_t *) vg;
+	return (vg_t) vg;
 }
 
-int lvm_vg_extend(vg_t *vg, const char *device)
+int lvm_vg_extend(vg_t vg, const char *device)
 {
 	if (vg_read_error(vg))
 		return -1;
@@ -72,7 +72,7 @@ int lvm_vg_extend(vg_t *vg, const char *device)
 	return 0;
 }
 
-int lvm_vg_reduce(vg_t *vg, const char *device)
+int lvm_vg_reduce(vg_t vg, const char *device)
 {
 	if (vg_read_error(vg))
 		return -1;
@@ -84,7 +84,7 @@ int lvm_vg_reduce(vg_t *vg, const char *device)
 	return 0;
 }
 
-int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
+int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size)
 {
 	if (vg_read_error(vg))
 		return -1;
@@ -96,7 +96,7 @@ int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 	return 0;
 }
 
-int lvm_vg_write(vg_t *vg)
+int lvm_vg_write(vg_t vg)
 {
 	struct pv_list *pvl;
 
@@ -138,7 +138,7 @@ int lvm_vg_write(vg_t *vg)
 	return 0;
 }
 
-int lvm_vg_close(vg_t *vg)
+int lvm_vg_close(vg_t vg)
 {
 	if (vg_read_error(vg) == FAILED_LOCKING)
 		vg_release(vg);
@@ -147,7 +147,7 @@ int lvm_vg_close(vg_t *vg)
 	return 0;
 }
 
-int lvm_vg_remove(vg_t *vg)
+int lvm_vg_remove(vg_t vg)
 {
 	if (vg_read_error(vg))
 		return -1;
@@ -162,11 +162,11 @@ int lvm_vg_remove(vg_t *vg)
 	return 0;
 }
 
-vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		  uint32_t flags)
 {
 	uint32_t internal_flags = 0;
-	vg_t *vg;
+	struct volume_group *vg;
 
 	if (!strncmp(mode, "w", 1))
 		internal_flags |= READ_FOR_UPDATE;
@@ -184,10 +184,10 @@ vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 	/* FIXME: combine this with locking ? */
 	vg->open_mode = mode[0];
 
-	return (vg_t *) vg;
+	return (vg_t) vg;
 }
 
-struct dm_list *lvm_vg_list_pvs(vg_t *vg)
+struct dm_list *lvm_vg_list_pvs(vg_t vg)
 {
 	struct dm_list *list;
 	pv_list_t *pvs;
@@ -214,7 +214,7 @@ struct dm_list *lvm_vg_list_pvs(vg_t *vg)
 	return list;
 }
 
-struct dm_list *lvm_vg_list_lvs(vg_t *vg)
+struct dm_list *lvm_vg_list_lvs(vg_t vg)
 {
 	struct dm_list *list;
 	lv_list_t *lvs;
@@ -241,43 +241,43 @@ struct dm_list *lvm_vg_list_lvs(vg_t *vg)
 	return list;
 }
 
-uint64_t lvm_vg_get_seqno(const vg_t *vg)
+uint64_t lvm_vg_get_seqno(const vg_t vg)
 {
 	return vg_seqno(vg);
 }
 
 /* FIXME: invalid handle? return INTMAX? */
-uint64_t lvm_vg_get_size(const vg_t *vg)
+uint64_t lvm_vg_get_size(const vg_t vg)
 {
 	return vg_size(vg);
 }
 
-uint64_t lvm_vg_get_free_size(const vg_t *vg)
+uint64_t lvm_vg_get_free_size(const vg_t vg)
 {
 	return vg_free(vg);
 }
 
-uint64_t lvm_vg_get_extent_size(const vg_t *vg)
+uint64_t lvm_vg_get_extent_size(const vg_t vg)
 {
 	return vg_extent_size(vg);
 }
 
-uint64_t lvm_vg_get_extent_count(const vg_t *vg)
+uint64_t lvm_vg_get_extent_count(const vg_t vg)
 {
 	return vg_extent_count(vg);
 }
 
-uint64_t lvm_vg_get_free_extent_count(const vg_t *vg)
+uint64_t lvm_vg_get_free_extent_count(const vg_t vg)
 {
 	return vg_free_count(vg);
 }
 
-uint64_t lvm_vg_get_pv_count(const vg_t *vg)
+uint64_t lvm_vg_get_pv_count(const vg_t vg)
 {
 	return vg_pv_count(vg);
 }
 
-char *lvm_vg_get_uuid(const vg_t *vg)
+char *lvm_vg_get_uuid(const vg_t vg)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -288,7 +288,7 @@ char *lvm_vg_get_uuid(const vg_t *vg)
 	return strndup((const char *)uuid, 64);
 }
 
-char *lvm_vg_get_name(const vg_t *vg)
+char *lvm_vg_get_name(const vg_t vg)
 {
 	char *name;
 
diff --git a/test/api/test.c b/test/api/test.c
index b2da3bf..65bc292 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -152,9 +152,9 @@ static lv_t *_lookup_lv_by_name(const char *name)
 	return lv;
 }
 
-static vg_t *_lookup_vg_by_name(char **argv, int argc)
+static vg_t _lookup_vg_by_name(char **argv, int argc)
 {
-	vg_t *vg;
+	vg_t vg;
 
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
@@ -203,7 +203,7 @@ static void _add_device_to_pvname_hash(struct dm_list *pvs, const char *name)
 }
 static void _vg_reduce(char **argv, int argc, lvm_t libh)
 {
-	vg_t *vg;
+	vg_t vg;
 	struct dm_list *pvs;
 
 	if (argc < 2) {
@@ -264,7 +264,7 @@ static void _config_reload(char **argv, int argc, lvm_t libh)
 
 static void _vg_extend(char **argv, int argc, lvm_t libh)
 {
-	vg_t *vg;
+	vg_t vg;
 	struct dm_list *pvs;
 
 	if (argc < 2) {
@@ -293,7 +293,7 @@ static void _vg_extend(char **argv, int argc, lvm_t libh)
 
 static void _vg_open(char **argv, int argc, lvm_t libh)
 {
-	vg_t *vg;
+	vg_t vg;
 	struct dm_list *lvs;
 	struct dm_list *pvs;
 
@@ -330,9 +330,9 @@ static void _vg_open(char **argv, int argc, lvm_t libh)
 		_add_pvs_to_pvname_hash(pvs);
 }
 /* Lookup the vg and remove it from the vgname and vgid hashes */
-static vg_t *_lookup_and_remove_vg(const char *vgname)
+static vg_t _lookup_and_remove_vg(const char *vgname)
 {
-	vg_t *vg=NULL;
+	vg_t vg=NULL;
 
 	if ((vg = dm_hash_lookup(_vgname_hash, vgname))) {
 		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
@@ -347,7 +347,7 @@ static vg_t *_lookup_and_remove_vg(const char *vgname)
 
 static void _vg_write(char **argv, int argc)
 {
-	vg_t *vg;
+	vg_t vg;
 	int rc = 0;
 
 	if (argc < 2) {
@@ -366,7 +366,7 @@ static void _vg_write(char **argv, int argc)
 
 static void _vg_create(char **argv, int argc, lvm_t libh)
 {
-	vg_t *vg;
+	vg_t vg;
 
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
@@ -385,7 +385,7 @@ static void _vg_create(char **argv, int argc, lvm_t libh)
 
 static void _vg_remove(char **argv, int argc)
 {
-	vg_t *vg;
+	vg_t vg;
 	int rc = 0;
 
 	if (argc < 2) {
@@ -404,7 +404,7 @@ static void _vg_remove(char **argv, int argc)
 
 static void _vg_close(char **argv, int argc)
 {
-	vg_t *vg;
+	vg_t vg;
 	int rc = 0;
 
 	if (argc < 2) {
@@ -421,7 +421,7 @@ static void _vg_close(char **argv, int argc)
 	printf("closing VG\n");
 }
 
-static void _show_one_vg(vg_t *vg)
+static void _show_one_vg(vg_t vg)
 {
 	printf("%s (%s): sz=%"PRIu64", free=%"PRIu64", #pv=%"PRIu64
 		", seq#=%"PRIu64"\n",
@@ -439,7 +439,7 @@ static void _pvs_in_vg(char **argv, int argc)
 {
 	struct dm_list *pvs;
 	struct lvm_pv_list *pvl;
-	vg_t *vg;
+	vg_t vg;
 
 	if (!(vg = _lookup_vg_by_name(argv, argc)))
 		return;
@@ -494,7 +494,7 @@ static void _lvs_in_vg(char **argv, int argc)
 {
 	struct dm_list *lvs;
 	struct lvm_lv_list *lvl;
-	vg_t *vg;
+	vg_t vg;
 
 	if (!(vg = _lookup_vg_by_name(argv, argc)))
 		return;
@@ -568,7 +568,7 @@ static void _vg_remove_lv(char **argv, int argc)
 
 static void _vg_create_lv_linear(char **argv, int argc)
 {
-	vg_t *vg;
+	vg_t vg;
 	lv_t *lv;
 
 	if (argc < 4) {
diff --git a/test/api/vgtest.c b/test/api/vgtest.c
index 432d5fe..8b82f39 100644
--- a/test/api/vgtest.c
+++ b/test/api/vgtest.c
@@ -24,7 +24,7 @@
 #include "lvm2app.h"
 
 lvm_t handle;
-vg_t *vg;
+vg_t vg;
 const char *vg_name = "my_vg";
 const char *device = "/dev/loop3";
 const char *device2 = "/dev/loop4";
-- 
1.6.0.6


