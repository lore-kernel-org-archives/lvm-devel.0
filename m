From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:20 -0400
Subject: [PATCH 07/30] Update lvkreadhead_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-7-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    7 +++++--
 lib/report/report.c          |    7 ++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index c92bc2b..e4b66b2 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -14,6 +14,7 @@
 #include "lvm.h"
 #include "lib.h"
 #include "metadata-exported.h"
+#include "activate.h"
 
 /**
  * lvm_lv_{get|set}_uuid
@@ -130,8 +131,10 @@ int lvm_lv_set_kernel_minor(lv_t *lv, const uint64_t value)
  */
 uint64_t lvm_lv_get_kernel_read_ahead(const lv_t *lv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	struct lvinfo info;
+	if (!lv_info(lv->vg->cmd, lv, &info, 0, 1) || !info.exists)
+		return -1;
+	return info.read_ahead;
 }
 int lvm_lv_set_kernel_read_ahead(lv_t *lv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index e933453..3bd4c45 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -685,12 +685,13 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			      void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	uint32_t value;
 
-	if (!lv_info(lv->vg->cmd, lv, &info, 0, 1) || !info.exists)
+	value = lvm_lv_get_kernel_read_ahead(lv);
+	if (value == -1)
 		return dm_report_field_uint64(rh, field, &_minusone);
 
-	return _size32_disp(rh, mem, field, &info.read_ahead, private);
+	return _size32_disp(rh, mem, field, &value, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
-- 
1.6.0.6


