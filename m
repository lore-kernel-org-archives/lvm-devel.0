From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:40 -0400
Subject: [PATCH 27/30] Update chunksize_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-27-git-send-email-dwysocha@redhat.com>
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
	<1242046903-15133-13-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-14-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-15-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-16-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-17-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-18-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-19-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-20-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-21-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-22-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-23-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-24-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-25-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-26-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-27-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-28-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    8 ++++++--
 lib/report/report.c          |    5 +----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 63b742f..6a35122 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -914,8 +914,12 @@ int lvm_lvseg_set_region_size(lvseg_t *lvseg, const uint64_t value)
  */
 uint64_t lvm_lvseg_get_chunk_size(const lvseg_t *lvseg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	uint64_t size;
+	if (lv_is_cow(lvseg->lv))
+		size = (uint64_t) find_cow(lvseg->lv)->chunk_size;
+	else
+		size = UINT64_C(0);
+	return size;
 }
 int lvm_lvseg_set_chunk_size(lvseg_t *lvseg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index e74dd1a..ece83df 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -803,10 +803,7 @@ static int _chunksize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
-	if (lv_is_cow(seg->lv))
-		size = (uint64_t) find_cow(seg->lv)->chunk_size;
-	else
-		size = UINT64_C(0);
+	size = lvm_lvseg_get_chunk_size(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.6.0.6


