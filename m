From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:05 +0000 (UTC)
Subject: master - report: report historical LV names with '-' prefix
Message-ID: <20160303132005.A2A32602AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f228750386ae4b5b00375e1a14139b53f86f9cca
Commit:        f228750386ae4b5b00375e1a14139b53f86f9cca
Parent:        8b9953e8c59ef4c3ced277cc40b8bb5006a24161
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:24:07 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

report: report historical LV names with '-' prefix

All names for historical LVs are prefixed with '-' character to make clear
difference between live and historical LVs. The '-' can't be set by users
for live LV names during lvcreate hence we never get into a conflict with
the names that user defines for live LVs.
---
 lib/report/report.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 8ef8eaf..dfc76bc 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1685,27 +1685,36 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	struct cmd_context *cmd = (struct cmd_context *) private;
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int is_historical = lv_is_historical(lv);
+	const char *tmp_lvname;
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_historical(lv))
-		return _string_disp(rh, mem, field, &lv->this_glv->historical->name, private);
-
-	if (lv_is_visible(lv) || !cmd->report_mark_hidden_devices)
+	if (!is_historical && (lv_is_visible(lv) || !cmd->report_mark_hidden_devices))
 		return _field_string(rh, field, lv->name);
 
-	len = strlen(lv->name) + 3;
+	if (is_historical) {
+		tmp_lvname = lv->this_glv->historical->name;
+		len = strlen(tmp_lvname) + strlen(HISTORICAL_LV_PREFIX) + 1;
+	} else {
+		tmp_lvname = lv->name;
+		len = strlen(tmp_lvname) + 3;
+	}
+
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, len, "[%s]", lv->name) < 0) {
+	if (dm_snprintf(repstr, len, "%s%s%s",
+			is_historical ? HISTORICAL_LV_PREFIX : "[",
+			tmp_lvname,
+			is_historical ? "" : "]") < 0) {
 		log_error("lvname snprintf failed");
 		return 0;
 	}
 
-	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
+	if (!(lvname = dm_pool_strdup(mem, tmp_lvname))) {
 		log_error("dm_pool_strdup failed");
 		return 0;
 	}


