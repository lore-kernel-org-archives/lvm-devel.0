From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Dec 2018 15:05:32 -0500
Subject: master - pvscan: use correct dev filters
Message-ID: <201812032005.wB3K5W4e014397@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1b2de936cf231c753c4c9f325d33ad5c746709e
Commit:        c1b2de936cf231c753c4c9f325d33ad5c746709e
Parent:        a063d2d123c56c4ccead986625a260df16556b9f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 3 12:58:46 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 3 12:58:46 2018 -0600

pvscan: use correct dev filters

pvscan was still using lvmetad_filter which has been
null since lvmetad was removed.  Switch it to use the
full_filter.
---
 tools/pvscan.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 0f7603e..884a824 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -539,7 +539,7 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 
 	label_scan(cmd);
 
-	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
 		log_error("dev_iter creation failed");
 		return;
 	}
@@ -680,7 +680,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	while (argc--) {
 		pv_name = *argv++;
 		if (pv_name[0] == '/') {
-			if (!(dev = dev_cache_get(cmd, pv_name, cmd->lvmetad_filter))) {
+			if (!(dev = dev_cache_get(cmd, pv_name, cmd->full_filter))) {
 				log_debug("pvscan arg %s not found.", pv_name);
 				if ((dev = dev_cache_get(cmd, pv_name, NULL))) {
 					/* nothing to do for this dev name */
@@ -707,7 +707,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			}
 			devno = MKDEV(major, minor);
 
-			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->lvmetad_filter))) {
+			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->full_filter))) {
 				log_debug("pvscan arg %d:%d not found.", major, minor);
 				_online_pvid_file_remove_devno(major, minor);
 			} else {
@@ -731,7 +731,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
+		label_scan_devs(cmd, cmd->full_filter, &single_devs);
 
 		dm_list_iterate_items(devl, &single_devs) {
 			dev = devl->dev;
@@ -763,7 +763,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 		devno = MKDEV(major, minor);
 
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->lvmetad_filter))) {
+		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->full_filter))) {
 			log_debug("pvscan arg %d:%d not found.", major, minor);
 			_online_pvid_file_remove_devno(major, minor);
 		} else {
@@ -782,7 +782,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
+		label_scan_devs(cmd, cmd->full_filter, &single_devs);
 
 		dm_list_iterate_items(devl, &single_devs) {
 			dev = devl->dev;


