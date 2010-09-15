From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:35:57 -0400
Subject: [PATCH 05/19] Add pv_uuid, vg_uuid, and lv_uuid, and call id_format_and_copy.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting functions for pv_uuid, vg_uuid, and lv_uuid.
Call new function id_format_and_copy.  Use 'const' where appropriate.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   15 +++++++++++++++
 lib/metadata/metadata.h |    3 +++
 liblvm/lvm_lv.c         |   10 ++--------
 liblvm/lvm_pv.c         |   10 ++--------
 liblvm/lvm_vg.c         |    8 +-------
 5 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 86f07e7..cb49d0f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4619,6 +4619,21 @@ char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv)
 	return repstr;
 }
 
+char *pv_uuid(const struct physical_volume *pv)
+{
+	return id_format_and_copy(pv->vg->vgmem, &pv->id);
+}
+
+char *vg_uuid(const struct volume_group *vg)
+{
+	return id_format_and_copy(vg->vgmem, &vg->id);
+}
+
+char *lv_uuid(const struct logical_volume *lv)
+{
+	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
+}
+
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
 	float percent;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1749f85..6e6d4c5 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -422,5 +422,8 @@ uint64_t vg_mda_free(const struct volume_group *vg);
 char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv);
 char *vg_attr(struct dm_pool *mem, const struct volume_group *vg);
 char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_uuid(const struct logical_volume *lv);
+char *vg_uuid(const struct volume_group *vg);
+char *pv_uuid(const struct physical_volume *pv);
 
 #endif
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 4519a7b..2cc7530 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -14,7 +14,7 @@
 
 #include "lib.h"
 #include "lvm2app.h"
-#include "metadata-exported.h"
+#include "metadata.h"
 #include "lvm-string.h"
 #include "defaults.h"
 #include "segtype.h"
@@ -39,13 +39,7 @@ uint64_t lvm_lv_get_size(const lv_t lv)
 
 const char *lvm_lv_get_uuid(const lv_t lv)
 {
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {
-		log_error(INTERNAL_ERROR "unable to convert uuid");
-		return NULL;
-	}
-	return dm_pool_strndup(lv->vg->vgmem, (const char *)uuid, 64);
+	return lv_uuid(lv);
 }
 
 const char *lvm_lv_get_name(const lv_t lv)
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index db2383c..e3962e4 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -14,18 +14,12 @@
 
 #include "lib.h"
 #include "lvm2app.h"
-#include "metadata-exported.h"
+#include "metadata.h"
 #include "lvm-string.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-		log_error(INTERNAL_ERROR "Unable to convert uuid");
-		return NULL;
-	}
-	return dm_pool_strndup(pv->vg->vgmem, (const char *)uuid, 64);
+	return pv_uuid(pv);
 }
 
 const char *lvm_pv_get_name(const pv_t pv)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a75652d..a2f8e31 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -327,13 +327,7 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg)
 
 const char *lvm_vg_get_uuid(const vg_t vg)
 {
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
-		log_error(INTERNAL_ERROR "Unable to convert uuid");
-		return NULL;
-	}
-	return dm_pool_strndup(vg->vgmem, (const char *)uuid, 64);
+	return vg_uuid(vg);
 }
 
 const char *lvm_vg_get_name(const vg_t vg)
-- 
1.7.2.1


