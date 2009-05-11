From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:32 -0400
Subject: [PATCH 19/30] Update pvmdas_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-19-git-send-email-dwysocha@redhat.com>
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
Message-ID: <1242046903-15133-20-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    9 +++++++--
 lib/report/report.c          |    6 ++----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index bed92b1..c07385c 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -563,8 +563,13 @@ int lvm_pv_set_tags(pv_t *pv, const char *value)
  */
 uint64_t lvm_pv_get_mda_count(const pv_t *pv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	struct lvmcache_info *info;
+	uint32_t count;
+	const char *pvid = (const char *)pv->id.uuid;
+
+	info = info_from_pvid(pvid, 0);
+	count = info ? dm_list_size(&info->mdas) : 0;
+	return count;
 }
 int lvm_pv_set_mda_count(pv_t *pv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index bb0c906..d387609 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -911,12 +911,10 @@ static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
-	struct lvmcache_info *info;
+	const struct physical_volume *pv = (const struct physical_volume *) data;
 	uint32_t count;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
-	info = info_from_pvid(pvid, 0);
-	count = info ? dm_list_size(&info->mdas) : 0;
+	count = lvm_pv_get_mda_count(pv);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
-- 
1.6.0.6


