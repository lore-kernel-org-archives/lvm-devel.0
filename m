From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:23 -0400
Subject: [PATCH 10/30] Update originsize_disp() to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-10-git-send-email-dwysocha@redhat.com>
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
Message-ID: <1242046903-15133-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |   11 +++++++++--
 lib/report/report.c          |    7 +------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 071d9ce..ab8cc9c 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -187,8 +187,15 @@ int lvm_lv_set_origin(lv_t *lv, const char *value)
  */
 uint64_t lvm_lv_get_origin_size(const lv_t *lv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	uint64_t size;
+
+	if (lv_is_cow(lv))
+		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
+	else if (lv_is_origin(lv))
+		size = lv->size;
+	else
+		size = UINT64_C(0);
+	return size;
 }
 int lvm_lv_set_origin_size(lv_t *lv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index 78aea9b..85addc9 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -775,12 +775,7 @@ static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	if (lv_is_cow(lv))
-		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
-	else if (lv_is_origin(lv))
-		size = lv->size;
-	else
-		size = UINT64_C(0);
+	size = lvm_lv_get_origin_size(lv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.6.0.6


