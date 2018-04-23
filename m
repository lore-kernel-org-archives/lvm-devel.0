From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:53:29 -0400
Subject: master - process_each_label: use lvmcache
Message-ID: <201804231353.w3NDrTrO001135@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4343280ebc0e2aae0de5fe959c24574b13d0d7be
Commit:        4343280ebc0e2aae0de5fe959c24574b13d0d7be
Parent:        f17c2cf7c614e8f6e4ffe9b7415d628ecab61d47
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 9 11:24:40 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

process_each_label: use lvmcache

In the same way as the other process_each functions.
In the common case all the info that's needed can be
used from lvmcache after a label scan.  But this means
that unchosen devs for duplicate PVs need to be handled
explicitly.
---
 tools/toollib.c |   60 ++++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 53 insertions(+), 7 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6593195..f6169ae 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1493,13 +1493,19 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 	struct label *label;
 	struct dev_iter *iter;
 	struct device *dev;
-
+	struct lvmcache_info *info;
+	struct dm_list process_duplicates;
+	struct device_list *devl;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int opt = 0;
 
+	dm_list_init(&process_duplicates);
+
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LABEL);
 
+	lvmcache_label_scan(cmd);
+
 	if (argc) {
 		for (; opt < argc; opt++) {
 			if (!(dev = dev_cache_get(argv[opt], cmd->full_filter))) {
@@ -1509,14 +1515,54 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 				continue;
 			}
 
+			if (!(label = lvmcache_get_dev_label(dev))) {
+				if (!lvmcache_dev_is_unchosen_duplicate(dev)) {
+					log_error("No physical volume label read from %s.", argv[opt]);
+					ret_max = ECMD_FAILED;
+				} else {
+					if (!(devl = dm_malloc(sizeof(*devl))))
+						return_0;
+					devl->dev = dev;
+					dm_list_add(&process_duplicates, &devl->list);
+				}
+				continue;
+			}
+
 			log_set_report_object_name_and_id(dev_name(dev), NULL);
 
-			if (!label_read(dev, &label, 0)) {
-				log_error("No physical volume label read from %s.",
-					  argv[opt]);
-				ret_max = ECMD_FAILED;
+			ret = process_single_label(cmd, label, handle);
+			report_log_ret_code(ret);
+
+			if (ret > ret_max)
+				ret_max = ret;
+
+			log_set_report_object_name_and_id(NULL, NULL);
+
+			if (sigint_caught())
+				break;
+		}
+
+		dm_list_iterate_items(devl, &process_duplicates) {
+			/* 
+			 * remove the existing dev for this pvid from lvmcache
+			 * so that the duplicate dev can replace it.
+			 */
+			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
+				lvmcache_del(info);
+
+			/*
+			 * add info to lvmcache from the duplicate dev.
+			 */
+			label_read(devl->dev, NULL, 0);
+
+			/*
+			 * the info/label should now be found because
+			 * the label_read should have added it.
+			 */
+			if (!(label = lvmcache_get_dev_label(devl->dev)))
 				continue;
-			}
+
+			log_set_report_object_name_and_id(dev_name(dev), NULL);
 
 			ret = process_single_label(cmd, label, handle);
 			report_log_ret_code(ret);
@@ -1541,7 +1587,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 
 	while ((dev = dev_iter_get(iter)))
 	{
-		if (!label_read(dev, &label, 0))
+		if (!(label = lvmcache_get_dev_label(dev)))
 			continue;
 
 		log_set_report_object_name_and_id(dev_name(label->dev), NULL);


