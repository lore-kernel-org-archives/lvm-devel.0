From: David Teigland <teigland@sourceware.org>
Date: Thu, 10 May 2018 17:19:18 -0400
Subject: master - pvscan: remove unused var warning
Message-ID: <201805102119.w4ALJIvn022526@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d974644db723cb608a2158a3a52b79194817572f
Commit:        d974644db723cb608a2158a3a52b79194817572f
Parent:        57bb46c5e7f8d6af1737af5ed1acae8abc37cded
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 10 16:18:36 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 10 16:18:36 2018 -0500

pvscan: remove unused var warning

---
 tools/pvscan.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index f1f1f8a..8493eaa 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -302,7 +302,6 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_list found_vgnames;
 	struct device *dev;
 	struct device_list *devl;
-	struct dev_filter *f;
 	const char *pv_name;
 	const char *reason = NULL;
 	int32_t major = -1;
@@ -507,8 +506,6 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	if (!dm_list_empty(&single_devs)) {
 		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
 
-		f = cmd->lvmetad_filter;
-
 		dm_list_iterate_items(devl, &single_devs) {
 			dev = devl->dev;
 
@@ -567,8 +564,6 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	if (!dm_list_empty(&single_devs)) {
 		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
 
-		f = cmd->lvmetad_filter;
-
 		dm_list_iterate_items(devl, &single_devs) {
 			dev = devl->dev;
 


