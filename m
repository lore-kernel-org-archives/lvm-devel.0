From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:19 -0400
Subject: [PATCH 07/20] Add pv_uuid_dup, vg_uuid_dup, and lv_uuid_dup, and call id_format_and_copy.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting functions for pv_uuid, vg_uuid, and lv_uuid.
Call new function id_format_and_copy.  Use 'const' where appropriate.
Add "_dup" suffix to indicate memory is being allocated.
Call {pv|vg|lv}_uuid_dup from lvm2app uuid functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c |    5 +++++
 lib/metadata/lv.h |    1 +
 lib/metadata/pv.c |    5 +++++
 lib/metadata/pv.h |    1 +
 lib/metadata/vg.c |    5 +++++
 lib/metadata/vg.h |    1 +
 liblvm/lvm_lv.c   |   10 ++--------
 liblvm/lvm_pv.c   |   10 ++--------
 liblvm/lvm_vg.c   |    8 +-------
 9 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6abcdab..4604653 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -16,6 +16,11 @@
 #include "metadata.h"
 #include "activate.h"
 
+char *lv_uuid_dup(const struct logical_volume *lv)
+{
+	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 4cf06b2..9e8dbe2 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -49,5 +49,6 @@ struct logical_volume {
 
 uint64_t lv_size(const struct logical_volume *lv);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_uuid_dup(const struct logical_volume *lv);
 
 #endif
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index a21b7d6..c60d825 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -29,6 +29,11 @@ struct id pv_id(const struct physical_volume *pv)
 	return pv_field(pv, id);
 }
 
+char *pv_uuid_dup(const struct physical_volume *pv)
+{
+	return id_format_and_copy(pv->vg->vgmem, &pv->id);
+}
+
 const struct format_type *pv_format_type(const struct physical_volume *pv)
 {
 	return pv_field(pv, fmt);
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 9e1c619..1df4957 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -56,6 +56,7 @@ struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
+char *pv_uuid_dup(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
 uint64_t pv_dev_size(const struct physical_volume *pv);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 07cb60a..c82eaa4 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -16,6 +16,11 @@
 #include "metadata.h"
 #include "activate.h"
 
+char *vg_uuid_dup(const struct volume_group *vg)
+{
+	return id_format_and_copy(vg->vgmem, &vg->id);
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index ebb44e0..b090894 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -124,5 +124,6 @@ unsigned snapshot_count(const struct volume_group *vg);
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
 char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg);
+char *vg_uuid_dup(const struct volume_group *vg);
 
 #endif
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 4519a7b..7bdafe0 100644
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
+	return lv_uuid_dup(lv);
 }
 
 const char *lvm_lv_get_name(const lv_t lv)
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index db2383c..0b6b6b1 100644
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
+	return pv_uuid_dup(pv);
 }
 
 const char *lvm_pv_get_name(const pv_t pv)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a75652d..a09208a 100644
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
+	return vg_uuid_dup(vg);
 }
 
 const char *lvm_vg_get_name(const vg_t vg)
-- 
1.7.2.2


