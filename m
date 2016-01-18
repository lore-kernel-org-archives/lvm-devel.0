From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 15:37:22 +0000 (UTC)
Subject: master - Revert "Revert "process_each_pv: remove unnecessary workaround""
Message-ID: <20160118153722.CF39160D63@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cd4d46f303ecf5212b5de0eb96c0a356453d289
Commit:        5cd4d46f303ecf5212b5de0eb96c0a356453d289
Parent:        06346eab849b272bcd99196a9b594da29abdb19a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 14 13:47:44 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 09:36:55 2016 -0600

Revert "Revert "process_each_pv: remove unnecessary workaround""

This reverts commit 6d09c8c2c45ea1dea243134b8badc841a87cc979.

Try again to remove the workaround.
---
 tools/toollib.c |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 728e61d..97cc1bf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3033,7 +3033,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	const char *pv_name;
 	int selected;
 	int process_pv;
-	int dev_found;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
@@ -3087,21 +3086,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			else
 				log_very_verbose("Processing PV %s in VG %s.", pv_name, vg->name);
 
-			dev_found = _device_list_remove(all_devices, pv->dev);
-
-			/*
-			 * FIXME PVs with no mdas may turn up in an orphan VG when
-			 * not using lvmetad as well as their correct VG.  They
-			 * will be missing from all_devices the second time
-			 * around but must not be processed twice or trigger a message.
-			 *
-			 * Missing PVs will also need processing even though they are
-			 * not present in all_devices.
-			 */
-			if (!dev_found && !is_missing_pv(pv)) {
-				log_verbose("Skipping PV %s in VG %s: not in device list.", pv_name, vg->name);
-				continue;
-			}
+			_device_list_remove(all_devices, pv->dev);
 
 			if (!skip) {
 				ret = process_single_pv(cmd, vg, pv, handle);


