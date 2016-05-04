From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  4 May 2016 16:30:40 +0000 (UTC)
Subject: master - pvcreate, pvremove: translate arg name to device once
Message-ID: <20160504163040.F1588606F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1df6769acabd99fe062ebac1c8290da1ef1020f7
Commit:        1df6769acabd99fe062ebac1c8290da1ef1020f7
Parent:        795e47cec572b13329eecbcfbbc0aa70f0bccc16
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 4 11:28:28 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 4 11:28:28 2016 -0500

pvcreate, pvremove: translate arg name to device once

Rather than doing repeated translations from name to
device when comparing args to existing PVs, do one
translation of the arg names and saving the device,
before checking existing PVs.
---
 tools/toollib.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ac2a57a..c86900a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3787,7 +3787,6 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
-	struct device *dev;
 	int found = 0;
 
 	if (!pv->dev)
@@ -3796,21 +3795,11 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	/*
 	 * Check if one of the command args in arg_devices
 	 * matches this device.
-	 *
-	 * (Possible optimization: the first time this _single
-	 * function is called, we could iterate through all
-	 * arg_devices entries, do the name to dev lookup
-	 * with dev_cache_get() and set the pd->dev fields.
-	 * Subsequent _single calls would just compare devs
-	 * and not do any dev_cache_get(). This would avoid
-	 * repeating dev_cache_get() for arg_devices entries.)
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices) {
-		dev = dev_cache_get(pd->name, cmd->full_filter);
-		if (dev != pv->dev)
+		if (pd->dev != pv->dev)
 			continue;
 
-		pd->dev = pv->dev;
 		if (pv->dev->pvid[0])
 			strncpy(pd->pvid, pv->dev->pvid, ID_LEN);
 		found = 1;
@@ -4015,7 +4004,6 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
 	struct label *label;
-	struct device *dev;
 	int found = 0;
 
 	if (!pv->dev)
@@ -4026,11 +4014,9 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 * matches this device.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices) {
-		dev = dev_cache_get(pd->name, cmd->full_filter);
-		if (dev != pv->dev)
+		if (pd->dev != pv->dev)
 			continue;
 
-		pd->dev = pv->dev;
 		if (pv->dev->pvid[0])
 			strncpy(pd->pvid, pv->dev->pvid, ID_LEN);
 		found = 1;
@@ -4240,6 +4226,12 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	dev_cache_full_scan(cmd->full_filter);
 
 	/*
+	 * Translate arg names into struct device's.
+	 */
+	dm_list_iterate_items(pd, &pp->arg_devices)
+		pd->dev = dev_cache_get(pd->name, cmd->full_filter);
+
+	/*
 	 * Use process_each_pv to search all existing PVs and devices.
 	 *
 	 * This is a slightly different way to use process_each_pv, because the


