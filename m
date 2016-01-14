From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 Jan 2016 15:13:25 +0000 (UTC)
Subject: master - Revert "process_each_pv: remove unnecessary workaround"
Message-ID: <20160114151325.A5C2A61173@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d09c8c2c45ea1dea243134b8badc841a87cc979
Commit:        6d09c8c2c45ea1dea243134b8badc841a87cc979
Parent:        88400b599efa2a06fcc29c1c69ef450aa0c98524
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 14 09:12:57 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 14 09:12:57 2016 -0600

Revert "process_each_pv: remove unnecessary workaround"

This reverts commit be1b1f3d8941543bcde2f42e65ed0f22fd07b122.
---
 tools/toollib.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 97cc1bf..728e61d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3033,6 +3033,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	const char *pv_name;
 	int selected;
 	int process_pv;
+	int dev_found;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
@@ -3086,7 +3087,21 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			else
 				log_very_verbose("Processing PV %s in VG %s.", pv_name, vg->name);
 
-			_device_list_remove(all_devices, pv->dev);
+			dev_found = _device_list_remove(all_devices, pv->dev);
+
+			/*
+			 * FIXME PVs with no mdas may turn up in an orphan VG when
+			 * not using lvmetad as well as their correct VG.  They
+			 * will be missing from all_devices the second time
+			 * around but must not be processed twice or trigger a message.
+			 *
+			 * Missing PVs will also need processing even though they are
+			 * not present in all_devices.
+			 */
+			if (!dev_found && !is_missing_pv(pv)) {
+				log_verbose("Skipping PV %s in VG %s: not in device list.", pv_name, vg->name);
+				continue;
+			}
 
 			if (!skip) {
 				ret = process_single_pv(cmd, vg, pv, handle);


