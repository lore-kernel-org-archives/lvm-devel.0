From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 Aug 2009 10:01:00 -0400
Subject: [PATCH 3/3] Make lvm2app pv_t handle definition consistent with lvm_t.
In-Reply-To: <1249999260-14593-3-git-send-email-dwysocha@redhat.com>
References: <1249999260-14593-1-git-send-email-dwysocha@redhat.com>
	<1249999260-14593-2-git-send-email-dwysocha@redhat.com>
	<1249999260-14593-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1249999260-14593-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch update pv_t handle to be consistent with lvm_t - define as a pointer
to internal struct physical_volume.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   12 ++++++------
 liblvm/lvm_pv.c  |    8 ++++----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 0d45a29..50ecce1 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -130,7 +130,7 @@ typedef struct logical_volume *lv_t;
  * group.  Changes will be written to disk when the volume group gets
  * committed to disk.
  */
-typedef struct physical_volume pv_t;
+typedef struct physical_volume *pv_t;
 
 /**
  * Logical Volume object list.
@@ -149,7 +149,7 @@ typedef struct lvm_lv_list {
  */
 typedef struct lvm_pv_list {
 	struct dm_list list;
-	pv_t *pv;
+	pv_t pv;
 } pv_list_t;
 
 /**
@@ -781,7 +781,7 @@ struct dm_list *lvm_vg_list_pvs(vg_t vg);
  * \return
  * Copy of the uuid string.
  */
-char *lvm_pv_get_uuid(const pv_t *pv);
+char *lvm_pv_get_uuid(const pv_t pv);
 
 /**
  * Get the current name of a logical volume.
@@ -795,7 +795,7 @@ char *lvm_pv_get_uuid(const pv_t *pv);
  * \return
  * Copy of the name.
  */
-char *lvm_pv_get_name(const pv_t *pv);
+char *lvm_pv_get_name(const pv_t pv);
 
 /**
  * Get the current number of metadata areas in the physical volume.
@@ -806,7 +806,7 @@ char *lvm_pv_get_name(const pv_t *pv);
  * \return
  * Number of metadata areas in the PV.
  */
-uint64_t lvm_pv_get_mda_count(const pv_t *pv);
+uint64_t lvm_pv_get_mda_count(const pv_t pv);
 
 /**
  * Resize physical volume to new_size bytes.
@@ -822,6 +822,6 @@ uint64_t lvm_pv_get_mda_count(const pv_t *pv);
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_pv_resize(const pv_t *pv, uint64_t new_size);
+int lvm_pv_resize(const pv_t pv, uint64_t new_size);
 
 #endif /* _LIB_LVM2APP_H */
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 3d67769..8548597 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -17,7 +17,7 @@
 #include "metadata-exported.h"
 #include "lvm-string.h"
 
-char *lvm_pv_get_uuid(const pv_t *pv)
+char *lvm_pv_get_uuid(const pv_t pv)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -28,7 +28,7 @@ char *lvm_pv_get_uuid(const pv_t *pv)
 	return strndup((const char *)uuid, 64);
 }
 
-char *lvm_pv_get_name(const pv_t *pv)
+char *lvm_pv_get_name(const pv_t pv)
 {
 	char *name;
 
@@ -38,12 +38,12 @@ char *lvm_pv_get_name(const pv_t *pv)
 	return name;
 }
 
-uint64_t lvm_pv_get_mda_count(const pv_t *pv)
+uint64_t lvm_pv_get_mda_count(const pv_t pv)
 {
 	return (uint64_t) pv_mda_count(pv);
 }
 
-int lvm_pv_resize(const pv_t *pv, uint64_t new_size)
+int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
 	log_error("NOT IMPLEMENTED YET");
-- 
1.6.0.6


