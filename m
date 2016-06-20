From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:28 +0000 (UTC)
Subject: master - log: use separate 'orphan' report object type for orphan VGs
Message-ID: <20160620094128.1E3DE61013@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cee1aedf12310866157b2112071850a59e6386b1
Commit:        cee1aedf12310866157b2112071850a59e6386b1
Parent:        89e2aef63a9a2b29b1f83a589d108c25236b4ae1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 14 13:21:53 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

log: use separate 'orphan' report object type for orphan VGs

---
 WHATS_NEW             |    1 +
 lib/log/log.c         |    1 +
 lib/log/lvm-logging.h |    1 +
 tools/toollib.c       |   32 ++++++++++++++++++++------------
 4 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f6e9e8..25494cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Use 'orphan' object type in cmd log for groups to collect PVs not yet in VGs.
   Add lvm lastlog command for query and display of last cmd's log in lvm shell.
   Report per-object return codes via cmd log while processing multiple objects.
   Annotate processing code with log report hooks for per-object command log.
diff --git a/lib/log/log.c b/lib/log/log.c
index 0bd2de9..e8793c6 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -298,6 +298,7 @@ const char *log_get_report_context_name(log_report_context_t context)
 const char *log_get_report_object_type_name(log_report_object_type_t object_type)
 {
 	static const char *log_object_type_names[LOG_REPORT_OBJECT_TYPE_COUNT] = {[LOG_REPORT_OBJECT_TYPE_NULL] = "",
+										  [LOG_REPORT_OBJECT_TYPE_ORPHAN] = "orphan",
 										  [LOG_REPORT_OBJECT_TYPE_PV] = "pv",
 										  [LOG_REPORT_OBJECT_TYPE_VG] = "vg",
 										  [LOG_REPORT_OBJECT_TYPE_LV] = "lv"};
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 5789c0b..e5b8b63 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -74,6 +74,7 @@ typedef enum {
 
 typedef enum {
 	LOG_REPORT_OBJECT_TYPE_NULL,
+	LOG_REPORT_OBJECT_TYPE_ORPHAN,
 	LOG_REPORT_OBJECT_TYPE_PV,
 	LOG_REPORT_OBJECT_TYPE_VG,
 	LOG_REPORT_OBJECT_TYPE_LV,
diff --git a/tools/toollib.c b/tools/toollib.c
index 41ef549..0eb2887 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1894,11 +1894,14 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		notfound = 0;
 
 		uuid[0] = '\0';
-		if (vg_uuid && !is_orphan_vg(vg_name) &&
-		    !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
-			stack;
-
-		log_set_report_object_name_and_id(vg_name, uuid);
+		if (is_orphan_vg(vg_name)) {
+			log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_ORPHAN);
+			log_set_report_object_name_and_id(vg_name + sizeof(VG_ORPHANS), uuid);
+		} else {
+			if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+				stack;
+			log_set_report_object_name_and_id(vg_name, uuid);
+		}
 
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
@@ -3306,7 +3309,8 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	log_set_report_object_group_and_group_id(vg->name, vg_uuid);
+	if (!is_orphan_vg(vg->name))
+		log_set_report_object_group_and_group_id(vg->name, vg_uuid);
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
@@ -3430,11 +3434,14 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		notfound = 0;
 
 		uuid[0] = '\0';
-		if (vg_uuid && !is_orphan_vg(vg_name) &&
-		    !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
-			stack;
-
-		log_set_report_object_name_and_id(vg_name, uuid);
+		if (is_orphan_vg(vg_name)) {
+			log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_ORPHAN);
+			log_set_report_object_name_and_id(vg_name + sizeof(VG_ORPHANS), uuid);
+		} else {
+			if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+				stack;
+			log_set_report_object_name_and_id(vg_name, uuid);
+		}
 
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
@@ -3750,7 +3757,8 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	if (!id_write_format(&vg->id, vg_uuid, sizeof(vg_uuid)))
 		stack;
 
-	log_set_report_object_group_and_group_id(vg->name, vg_uuid);
+	if (!is_orphan_vg(vg->name))
+		log_set_report_object_group_and_group_id(vg->name, vg_uuid);
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv_uuid[0] = '\0';


