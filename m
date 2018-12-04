From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Dec 2018 15:11:03 -0500
Subject: master - remove unused full filter
Message-ID: <201812042011.wB4KB3Wh024229@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d2fd95af78c6f8a34c2d602285bd2230d89b3fd
Commit:        3d2fd95af78c6f8a34c2d602285bd2230d89b3fd
Parent:        89c11a2b49182f6858629857b8c6b3ba126c5970
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 4 14:06:46 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 4 14:06:46 2018 -0600

remove unused full filter

it's the same as cmd->filter
---
 lib/cache/lvmcache.c       |    4 ++--
 lib/commands/toolcontext.c |   10 ++++------
 lib/commands/toolcontext.h |    3 +--
 lib/label/label.c          |    4 ++--
 tools/lvmdiskscan.c        |    4 ++--
 tools/pvscan.c             |   12 ++++++------
 tools/reporter.c           |    2 +-
 tools/toollib.c            |    8 ++++----
 8 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d35b366..da8b4d8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -857,8 +857,8 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	_scanning_in_progress = 1;
 
 	/* FIXME: can this happen? */
-	if (!cmd->full_filter) {
-		log_error("label scan is missing full filter");
+	if (!cmd->filter) {
+		log_error("label scan is missing filter");
 		goto out;
 	}
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8b2ab4e..c42ed56 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1181,9 +1181,7 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 		goto bad;
 	}
 
-	cmd->filter = filter = pfilter;
-
-	cmd->full_filter = filter;
+	cmd->filter = pfilter;
 
 	cmd->initialized.filters = 1;
 	return 1;
@@ -1834,9 +1832,9 @@ static void _destroy_dev_types(struct cmd_context *cmd)
 
 static void _destroy_filters(struct cmd_context *cmd)
 {
-	if (cmd->full_filter) {
-		cmd->full_filter->destroy(cmd->full_filter);
-		cmd->filter = cmd->full_filter = NULL;
+	if (cmd->filter) {
+		cmd->filter->destroy(cmd->filter);
+		cmd->filter = NULL;
 	}
 	cmd->initialized.filters = 0;
 }
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f820ba1..6396f6c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -176,8 +176,7 @@ struct cmd_context {
 	/*
 	 * Filtering.
 	 */
-	struct dev_filter *filter;		/* post-lvmetad filter chain */
-	struct dev_filter *full_filter;		/* lvmetad_filter + filter */
+	struct dev_filter *filter;
 
 	/*
 	 * Configuration.
diff --git a/lib/label/label.c b/lib/label/label.c
index 1fb374e..0517312 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -855,7 +855,7 @@ int label_scan(struct cmd_context *cmd)
 	 */
 	dev_cache_scan();
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
+	if (!(iter = dev_iter_create(cmd->filter, 0))) {
 		log_error("Scanning failed to get devices.");
 		return 0;
 	}
@@ -898,7 +898,7 @@ int label_scan(struct cmd_context *cmd)
 			return 0;
 	}
 
-	_scan_list(cmd, cmd->full_filter, &all_devs, NULL);
+	_scan_list(cmd, cmd->filter, &all_devs, NULL);
 
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index 0b97eba..a504c3a 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -100,9 +100,9 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	/* Call before using dev_iter which uses filters which want bcache data. */
 	label_scan(cmd);
 
-	max_len = _get_max_dev_name_len(cmd, cmd->full_filter);
+	max_len = _get_max_dev_name_len(cmd, cmd->filter);
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
+	if (!(iter = dev_iter_create(cmd->filter, 0))) {
 		log_error("dev_iter_create failed");
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 884a824..2a884df 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -539,7 +539,7 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 
 	label_scan(cmd);
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed");
 		return;
 	}
@@ -680,7 +680,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	while (argc--) {
 		pv_name = *argv++;
 		if (pv_name[0] == '/') {
-			if (!(dev = dev_cache_get(cmd, pv_name, cmd->full_filter))) {
+			if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
 				log_debug("pvscan arg %s not found.", pv_name);
 				if ((dev = dev_cache_get(cmd, pv_name, NULL))) {
 					/* nothing to do for this dev name */
@@ -707,7 +707,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			}
 			devno = MKDEV(major, minor);
 
-			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->full_filter))) {
+			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter))) {
 				log_debug("pvscan arg %d:%d not found.", major, minor);
 				_online_pvid_file_remove_devno(major, minor);
 			} else {
@@ -731,7 +731,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->full_filter, &single_devs);
+		label_scan_devs(cmd, cmd->filter, &single_devs);
 
 		dm_list_iterate_items(devl, &single_devs) {
 			dev = devl->dev;
@@ -763,7 +763,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 		devno = MKDEV(major, minor);
 
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->full_filter))) {
+		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter))) {
 			log_debug("pvscan arg %d:%d not found.", major, minor);
 			_online_pvid_file_remove_devno(major, minor);
 		} else {
@@ -782,7 +782,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->full_filter, &single_devs);
+		label_scan_devs(cmd, cmd->filter, &single_devs);
 
 		dm_list_iterate_items(devl, &single_devs) {
 			dev = devl->dev;
diff --git a/tools/reporter.c b/tools/reporter.c
index cd2a41e..c321d21 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -719,7 +719,7 @@ static void _check_pv_list(struct cmd_context *cmd, struct report_args *args, st
 
 	if (single_args->args_are_pvs && args->argc) {
 		for (i = 0; i < args->argc; i++) {
-			if (!rescan_done && !dev_cache_get(cmd, args->argv[i], cmd->full_filter)) {
+			if (!rescan_done && !dev_cache_get(cmd, args->argv[i], cmd->filter)) {
 				cmd->filter->wipe(cmd->filter);
 				/* FIXME scan only one device */
 				lvmcache_label_scan(cmd);
diff --git a/tools/toollib.c b/tools/toollib.c
index 6c38eb2..d8394a3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1477,7 +1477,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 
 	if (argc) {
 		for (; opt < argc; opt++) {
-			if (!(dev = dev_cache_get(cmd, argv[opt], cmd->full_filter))) {
+			if (!(dev = dev_cache_get(cmd, argv[opt], cmd->filter))) {
 				log_error("Failed to find device "
 					  "\"%s\".", argv[opt]);
 				ret_max = ECMD_FAILED;
@@ -1548,7 +1548,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		goto out;
 	}
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed.");
 		ret_max = ECMD_FAILED;
 		goto out;
@@ -3917,7 +3917,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 
 	log_debug("Getting list of all devices");
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
 	}
@@ -5424,7 +5424,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * Translate arg names into struct device's.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices)
-		pd->dev = dev_cache_get(cmd, pd->name, cmd->full_filter);
+		pd->dev = dev_cache_get(cmd, pd->name, cmd->filter);
 
 	/*
 	 * Use process_each_pv to search all existing PVs and devices.


