From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 12:06:19 +0000 (UTC)
Subject: master - log: add 'label' log report object type; annotate process_each_label with log_set_report_object_{type, id_and_name} and report_log_ret_code
Message-ID: <20160620120619.D531260F60@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a77732c18089a12fa7c009a02cc1f1d6636a4284
Commit:        a77732c18089a12fa7c009a02cc1f1d6636a4284
Parent:        db6b4c1eef733769a3ca9f2f01c29c77cf83cc24
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 20 13:46:35 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 14:05:13 2016 +0200

log: add 'label' log report object type; annotate process_each_label with log_set_report_object_{type, id_and_name} and report_log_ret_code

---
 lib/log/log.c         |    1 +
 lib/log/lvm-logging.h |    1 +
 tools/toollib.c       |   21 ++++++++++++++++++---
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index e8793c6..0d253e7 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -300,6 +300,7 @@ const char *log_get_report_object_type_name(log_report_object_type_t object_type
 	static const char *log_object_type_names[LOG_REPORT_OBJECT_TYPE_COUNT] = {[LOG_REPORT_OBJECT_TYPE_NULL] = "",
 										  [LOG_REPORT_OBJECT_TYPE_ORPHAN] = "orphan",
 										  [LOG_REPORT_OBJECT_TYPE_PV] = "pv",
+										  [LOG_REPORT_OBJECT_TYPE_LABEL] = "label",
 										  [LOG_REPORT_OBJECT_TYPE_VG] = "vg",
 										  [LOG_REPORT_OBJECT_TYPE_LV] = "lv"};
 	return log_object_type_names[object_type];
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index e5b8b63..59ed7ac 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -76,6 +76,7 @@ typedef enum {
 	LOG_REPORT_OBJECT_TYPE_NULL,
 	LOG_REPORT_OBJECT_TYPE_ORPHAN,
 	LOG_REPORT_OBJECT_TYPE_PV,
+	LOG_REPORT_OBJECT_TYPE_LABEL,
 	LOG_REPORT_OBJECT_TYPE_VG,
 	LOG_REPORT_OBJECT_TYPE_LV,
 	LOG_REPORT_OBJECT_TYPE_COUNT
diff --git a/tools/toollib.c b/tools/toollib.c
index fe9f9c0..833d6ce 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1456,6 +1456,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		       struct processing_handle *handle,
 		       process_single_label_fn_t process_single_label)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
 	struct label *label;
 	struct dev_iter *iter;
 	struct device *dev;
@@ -1464,6 +1465,8 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 	int ret;
 	int opt = 0;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LABEL);
+
 	if (argc) {
 		for (; opt < argc; opt++) {
 			if (!(dev = dev_cache_get(argv[opt], cmd->full_filter))) {
@@ -1473,6 +1476,8 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 				continue;
 			}
 
+			log_set_report_object_name_and_id(dev_name(dev), NULL);
+
 			if (!label_read(dev, &label, 0)) {
 				log_error("No physical volume label read from %s.",
 					  argv[opt]);
@@ -1481,20 +1486,24 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			}
 
 			ret = process_single_label(cmd, label, handle);
+			report_log_ret_code(ret);
 
 			if (ret > ret_max)
 				ret_max = ret;
 
+			log_set_report_object_name_and_id(NULL, NULL);
+
 			if (sigint_caught())
 				break;
 		}
 
-		return ret_max;
+		goto out;
 	}
 
 	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
 		log_error("dev_iter creation failed.");
-		return ECMD_FAILED;
+		ret_max = ECMD_FAILED;
+		goto out;
 	}
 
 	while ((dev = dev_iter_get(iter)))
@@ -1502,17 +1511,23 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		if (!label_read(dev, &label, 0))
 			continue;
 
+		log_set_report_object_name_and_id(dev_name(label->dev), NULL);
+
 		ret = process_single_label(cmd, label, handle);
+		report_log_ret_code(ret);
 
 		if (ret > ret_max)
 			ret_max = ret;
 
+		log_set_report_object_name_and_id(NULL, NULL);
+
 		if (sigint_caught())
 			break;
 	}
 
 	dev_iter_destroy(iter);
-
+out:
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 


