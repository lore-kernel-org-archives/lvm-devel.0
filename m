From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:19 -0400
Subject: [PATCH 06/30] Update lvreadahead_disp to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-6-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.  Just move the dereference inside 'get'
function and call from 'disp' function.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    3 +--
 lib/report/report.c          |    6 ++++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index 15b7991..c92bc2b 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -89,8 +89,7 @@ int lvm_lv_set_minor(lv_t *lv, const uint64_t value)
  */
 uint64_t lvm_lv_get_read_ahead(const lv_t *lv)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return lv->read_ahead;
 }
 int lvm_lv_set_read_ahead(lv_t *lv, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index e43f9b4..e933453 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -668,13 +668,15 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			     const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint32_t value;
 
-	if (lv->read_ahead == DM_READ_AHEAD_AUTO) {
+	value = lvm_lv_get_read_ahead(lv);
+	if (value == DM_READ_AHEAD_AUTO) {
 		dm_report_field_set_value(field, "auto", &_minusone);
 		return 1;
 	}
 
-	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
+	return _size32_disp(rh, mem, field, &value, private);
 }
 
 static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
-- 
1.6.0.6


