From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:42 -0400
Subject: [PATCH 29/30] Update segsize_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-29-git-send-email-dwysocha@redhat.com>
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
	<1242046903-15133-29-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-30-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    3 +--
 lib/report/report.c          |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index dc80752..1bda95b 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -958,8 +958,7 @@ int lvm_lvseg_set_start_pe(lvseg_t *lvseg, const uint64_t value)
  */
 uint64_t lvm_lvseg_get_size(const lvseg_t *lvseg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return (uint64_t) lvseg->len * lvseg->lv->vg->extent_size;
 }
 int lvm_lvseg_set_size(lvseg_t *lvseg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index b59e6a1..e91cef2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -758,7 +758,7 @@ static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
-	size = (uint64_t) seg->len * seg->lv->vg->extent_size;
+	size = lvm_lvseg_get_size(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.6.0.6


