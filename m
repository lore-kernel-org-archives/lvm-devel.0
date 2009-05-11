From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:30 -0400
Subject: [PATCH 17/30] Update pvused_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-17-git-send-email-dwysocha@redhat.com>
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
Message-ID: <1242046903-15133-18-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    9 +++++++--
 lib/report/report.c          |    5 +----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index a205801..bed92b1 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -490,8 +490,13 @@ int lvm_pv_set_free(pv_t *pv, const uint64_t value)
  */
 uint64_t lvm_pv_get_used(const pv_t *pv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	uint64_t used;
+
+	if (!pv->pe_count)
+		used = 0LL;
+	else
+		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+	return used;
 }
 int lvm_pv_set_used(pv_t *pv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index b2568b2..d2a5c0a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -788,10 +788,7 @@ static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
 	    (const struct physical_volume *) data;
 	uint64_t used;
 
-	if (!pv->pe_count)
-		used = 0LL;
-	else
-		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+	used = lvm_pv_get_used(pv);
 
 	return _size64_disp(rh, mem, field, &used, private);
 }
-- 
1.6.0.6


