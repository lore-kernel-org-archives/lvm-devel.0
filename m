From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:22 -0400
Subject: [PATCH 09/30] Update lvsegcount_disp() to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-9-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    3 +--
 lib/report/report.c          |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index e4b66b2..071d9ce 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -160,8 +160,7 @@ int lvm_lv_set_size(lv_t *lv, const uint64_t value)
  */
 uint64_t lvm_lv_get_seg_count(const lv_t *lv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return dm_list_size(&lv->segments);
 }
 int lvm_lv_set_seg_count(lv_t *lv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index cc522c4..78aea9b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1020,7 +1020,7 @@ static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint32_t count;
 
-	count = dm_list_size(&lv->segments);
+	count = lvm_lv_get_seg_count(lv);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
-- 
1.6.0.6


