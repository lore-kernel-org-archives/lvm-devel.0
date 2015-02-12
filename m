From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Feb 2015 13:18:41 +0000 (UTC)
Subject: master - toollib: process_each_pv: fix commit d38d047e which worked for processing "all devices", but didn't work for "all PVs"
Message-ID: <20150212131841.E105160CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d95c6154ffe19e629a1403b45f6e8371f9dc6d70
Commit:        d95c6154ffe19e629a1403b45f6e8371f9dc6d70
Parent:        e52c998c490a4895fb7decfcde462455a68dc8e5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 12 14:14:45 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 12 14:14:45 2015 +0100

toollib: process_each_pv: fix commit d38d047e which worked for processing "all devices", but didn't work for "all PVs"

We still need to get the list as the calls underneath process_each_pv
rely on this list. But still keep the change related to the filters -
if we're processing all devices, we need to use cmd->full_filter.
If we're processing only PVs, we can use cmd->filter only to save
some time which would be spent in filtering code.
---
 tools/toollib.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6452605..43c7fc1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2330,7 +2330,8 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
+static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices,
+			    int use_full_filter)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -2339,7 +2340,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
+	if (!(iter = dev_iter_create(use_full_filter ? cmd->full_filter : cmd->filter, 1))) {
 		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
 	}
@@ -2736,8 +2737,7 @@ int process_each_pv(struct cmd_context *cmd,
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
 	 */
-	if (process_all_devices &&
-	    (ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
+	if ((ret = _get_all_devices(cmd, &all_devices, process_all_devices) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}


