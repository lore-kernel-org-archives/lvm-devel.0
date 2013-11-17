From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:48 +0000 (UTC)
Subject: master - toollib: Implement process_each_label.
Message-ID: <20131117222648.432FF6103A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ef2c3c4ee325dd9ce607b62c1720d782021d399
Commit:        1ef2c3c4ee325dd9ce607b62c1720d782021d399
Parent:        9b91977f4ec21a2080daaa2e261fbdecbe8fbd2c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 18:51:27 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

toollib: Implement process_each_label.

---
 tools/toollib.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    6 +++++
 2 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 127dd66..529088c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1801,3 +1801,61 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
+int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *handle,
+		       process_single_label_fn_t process_single_label)
+{
+	struct label *label;
+	struct dev_iter *iter;
+	struct device *dev;
+
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+	int opt = 0;
+
+	if (argc) {
+		for (; opt < argc; opt++) {
+			if (!(dev = dev_cache_get(argv[opt], cmd->filter))) {
+				log_error("Failed to find device "
+					  "\"%s\"", argv[opt]);
+				ret_max = ECMD_FAILED;
+				continue;
+			}
+
+			if (!label_read(dev, &label, 0))
+				continue;
+
+			ret = process_single_label(cmd, label, handle);
+
+			if (ret > ret_max)
+				ret_max = ret;
+
+			if (sigint_caught())
+				break;
+		}
+
+		return ret_max;
+	}
+
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+		log_error("dev_iter creation failed");
+		return ECMD_FAILED;
+	}
+
+	while ((dev = dev_iter_get(iter)))
+	{
+		if (!label_read(dev, &label, 0))
+			continue;
+
+		ret = process_single_label(cmd, label, handle);
+
+		if (ret > ret_max)
+			ret_max = ret;
+
+		if (sigint_caught())
+			break;
+	}
+
+	dev_iter_destroy(iter);
+
+	return ret_max;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index aa6f699..d809123 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -38,6 +38,9 @@ typedef int (*process_single_pv_fn_t) (struct cmd_context *cmd,
 				  struct volume_group *vg,
 				  struct physical_volume *pv,
 				  void *handle);
+typedef int (*process_single_label_fn_t) (struct cmd_context *cmd,
+					  struct label *label,
+					  void *handle);
 typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
 				  struct logical_volume *lv,
 				  void *handle);
@@ -58,6 +61,9 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    int scan_label_only, void *handle,
 		    process_single_pv_fn_t process_single_pv);
 
+int process_each_label(struct cmd_context *cmd, int argc, char **argv,
+		       void *handle, process_single_label_fn_t process_single_label);
+
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,


