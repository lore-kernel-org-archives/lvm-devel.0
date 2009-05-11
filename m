From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:28 -0400
Subject: [PATCH 15/30] Update pvsize_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-15-git-send-email-dwysocha@redhat.com>
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
Message-ID: <1242046903-15133-16-git-send-email-dwysocha@redhat.com>
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
index 726d2b6..0c79258 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -451,8 +451,13 @@ int lvm_pv_set_pe_start(pv_t *pv, const uint64_t value)
  */
 uint64_t lvm_pv_get_size(const pv_t *pv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	uint64_t size;
+
+	if (!pv->pe_count)
+		size = pv->size;
+	else
+		size = (uint64_t) pv->pe_count * pv->pe_size;
+	return size;
 }
 int lvm_pv_set_size(pv_t *pv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index fc54f96..a5d4a69 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -833,10 +833,7 @@ static int _pvsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	    (const struct physical_volume *) data;
 	uint64_t size;
 
-	if (!pv->pe_count)
-		size = pv->size;
-	else
-		size = (uint64_t) pv->pe_count * pv->pe_size;
+	size = lvm_pv_get_size(pv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.6.0.6


