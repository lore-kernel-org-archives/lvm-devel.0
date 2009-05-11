From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:41 -0400
Subject: [PATCH 28/30] Update segstart_disp and segstartpe_disp to call liblvm 'get' functions.
In-Reply-To: <1242046903-15133-28-git-send-email-dwysocha@redhat.com>
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
	<1242046903-15133-28-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-29-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    6 ++----
 lib/report/report.c          |    7 +++++--
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 6a35122..dc80752 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -932,8 +932,7 @@ int lvm_lvseg_set_chunk_size(lvseg_t *lvseg, const uint64_t value)
  */
 uint64_t lvm_lvseg_get_start(const lvseg_t *lvseg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return (uint64_t) lvseg->le * lvseg->lv->vg->extent_size;
 }
 int lvm_lvseg_set_start(lvseg_t *lvseg, const uint64_t value)
 {
@@ -946,8 +945,7 @@ int lvm_lvseg_set_start(lvseg_t *lvseg, const uint64_t value)
  */
 uint64_t lvm_lvseg_get_start_pe(const lvseg_t *lvseg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return lvseg->le;
 }
 int lvm_lvseg_set_start_pe(lvseg_t *lvseg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index ece83df..b59e6a1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -732,7 +732,7 @@ static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t start;
 
-	start = (uint64_t) seg->le * seg->lv->vg->extent_size;
+	start = lvm_lvseg_get_start(seg);
 
 	return _size64_disp(rh, mem, field, &start, private);
 }
@@ -744,8 +744,11 @@ static int _segstartpe_disp(struct dm_report *rh,
 			    void *private __attribute((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
+	uint32_t start;
 
-	return dm_report_field_uint32(rh, field, &seg->le);
+	start = lvm_lvseg_get_start_pe(seg);
+
+	return dm_report_field_uint32(rh, field, &start);
 }
 
 static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
-- 
1.6.0.6


