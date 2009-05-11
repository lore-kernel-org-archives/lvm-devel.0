From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:25 -0400
Subject: [PATCH 12/30] Update pvmdafree_disp() to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-12-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-10-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-11-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-12-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the guts of pvmadfree_disp() inside liblvm 'get' function.
As we do this, we must add a few more includes into lvm_object_prop.c
as we are now dereferencing internal lvm types to get the field values.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |   22 ++++++++++++++++++++--
 lib/report/report.c          |   18 +++---------------
 2 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 27690a6..8f8b5d7 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -16,6 +16,9 @@
 #include "metadata-exported.h"
 #include "activate.h"
 #include "device.h"
+#include "lvmcache.h"
+#include "uuid.h"
+#include "metadata.h"
 
 /**
  * lvm_lv_{get|set}_uuid
@@ -366,8 +369,23 @@ int lvm_pv_set_name(pv_t *pv, const char *value)
  */
 uint64_t lvm_pv_get_mda_free(const pv_t *pv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	struct lvmcache_info *info;
+	uint64_t freespace = UINT64_MAX, mda_free;
+	const char *pvid = (const char *)pv->id.uuid;
+	struct metadata_area *mda;
+
+	if ((info = info_from_pvid(pvid, 0)))
+		dm_list_iterate_items(mda, &info->mdas) {
+			if (!mda->ops->mda_free_sectors)
+				continue;
+			mda_free = mda->ops->mda_free_sectors(mda);
+			if (mda_free < freespace)
+				freespace = mda_free;
+		}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
 }
 int lvm_pv_set_mda_free(pv_t *pv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index 02e61de..1fa7aa6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -907,22 +907,10 @@ static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	struct lvmcache_info *info;
-	uint64_t freespace = UINT64_MAX, mda_free;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
-	struct metadata_area *mda;
-
-	if ((info = info_from_pvid(pvid, 0)))
-		dm_list_iterate_items(mda, &info->mdas) {
-			if (!mda->ops->mda_free_sectors)
-				continue;
-			mda_free = mda->ops->mda_free_sectors(mda);
-			if (mda_free < freespace)
-				freespace = mda_free;
-		}
+	const struct physical_volume *pv = (const struct physical_volume *) data;
+	uint64_t freespace;
 
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
+	freespace = lvm_pv_get_mda_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
-- 
1.6.0.6


