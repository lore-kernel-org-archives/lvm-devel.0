From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Jan 2016 16:46:09 +0000 (UTC)
Subject: master - process_each_pv: remove unnecessary workaround
Message-ID: <20160113164609.67BFB6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be1b1f3d8941543bcde2f42e65ed0f22fd07b122
Commit:        be1b1f3d8941543bcde2f42e65ed0f22fd07b122
Parent:        63d59254d95e29a4e6ca47cadfb15cf821ec7479
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 13 10:43:01 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 13 10:46:04 2016 -0600

process_each_pv: remove unnecessary workaround

The problem addressed by this workaround no longer
seems to exist, so remove it.  PVs with no mdas
no longer appear in both their actual VG and in
the orphan VG.
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


