From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 25 Jul 2009 23:03:38 -0400
Subject: [PATCH] Add most all liblvm 'get' functions needed for anaconda.
Message-ID: <1248577419-25724-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the most straightforward 'get' functions required for anaconda.
These are the ones that return simple uint64_t values.
The other more complex ones involve the lv_attr bits.  These will
come in a separate patch series since each lv_attr bit will be returned
in a separate API instred of returning the string and requiring the
user to parse it.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm.h    |   15 +++++++++++++++
 liblvm/lvm_lv.c |    3 +++
 liblvm/lvm_pv.c |   11 +++++++++++
 liblvm/lvm_vg.c |   20 ++++++++++++++++++++
 4 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index f2080f7..a39f198 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -243,6 +243,21 @@ char *lvm_vg_get_name(const vg_t *vg);
 char *lvm_lv_get_name(const lv_t *lv);
 
 /**
+ * Get various pv, vg, or lv properties.
+ * For full description of each property, consult the man pages for pvs,
+ * vgs, and lvs.
+ * FIXME: What value to return for invalid handle or other errors?
+ */
+uint64_t lvm_pv_get_mda_count(const pv_t *pv);
+uint64_t lvm_vg_get_size(const vg_t *vg);
+uint64_t lvm_vg_get_free(const vg_t *vg);
+uint64_t lvm_vg_get_extent_size(const vg_t *vg);
+uint64_t lvm_vg_get_extent_count(const vg_t *vg);
+uint64_t lvm_vg_get_free_count(const vg_t *vg);
+uint64_t lvm_vg_get_pv_count(const vg_t *vg);
+uint64_t lvm_lv_get_size(const lv_t *lv);
+
+/**
  * Close a VG opened with lvm_vg_create
  *
  * This API releases a VG handle and any resources associated with the handle.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index e914d6c..5b1b213 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -20,6 +20,9 @@
 #include "segtype.h"
 #include <string.h>
 
+inline uint64_t lvm_lv_get_size(const lv_t *lv)
+{ return (uint64_t) lv->size; }
+
 char *lvm_lv_get_uuid(const lv_t *lv)
 {
 	char uuid[64] __attribute((aligned(8)));
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 0618a84..19d0ce6 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -16,6 +16,8 @@
 #include "lvm.h"
 #include "metadata-exported.h"
 #include "lvm-string.h"
+#include "uuid.h"
+#include "lvmcache.h"
 
 char *lvm_pv_get_uuid(const pv_t *pv)
 {
@@ -38,3 +40,12 @@ char *lvm_pv_get_name(const pv_t *pv)
 	return name;
 }
 
+/* FIXME: have pvmdas_disp call this function */
+uint64_t lvm_pv_get_mda_count(const pv_t *pv)
+{
+	struct lvmcache_info *info;
+	const char *pvid = (const char *)pv->id.uuid;
+
+	info = info_from_pvid(pvid, 0);
+	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
+}
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index bd6b36d..e64e3f9 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -194,6 +194,26 @@ struct dm_list *lvm_vg_list_lvs(vg_t *vg)
 	return list;
 }
 
+/* FIXME: have *_disp functions from report.c call these functions */
+/* FIXME: invalid handle? return INTMAX? */
+inline uint64_t lvm_vg_get_size(const vg_t *vg)
+{ return (uint64_t) vg->extent_count * vg->extent_size; }
+
+inline uint64_t lvm_vg_get_free(const vg_t *vg)
+{ return (uint64_t) vg->free_count * vg->extent_size; }
+
+inline uint64_t lvm_vg_get_extent_size(const vg_t *vg)
+{ return (uint64_t) vg->extent_size; }
+
+inline uint64_t lvm_vg_get_extent_count(const vg_t *vg)
+{ return (uint64_t) vg->extent_count; }
+
+inline uint64_t lvm_vg_get_free_count(const vg_t *vg)
+{ return (uint64_t) vg->free_count; }
+
+inline uint64_t lvm_vg_get_pv_count(const vg_t *vg)
+{ return (uint64_t) vg->pv_count; }
+
 char *lvm_vg_get_uuid(const vg_t *vg)
 {
 	char uuid[64] __attribute((aligned(8)));
-- 
1.6.0.6


