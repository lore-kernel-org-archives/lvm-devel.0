From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Oct 2013 11:19:57 +0000 (UTC)
Subject: master - activation: check for open count with a timeout before removal/deactivation of an LV
Message-ID: <20131015111957.AE7406002B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48df36b8c531a43da8602b50759c9e841e1d9f44
Commit:        48df36b8c531a43da8602b50759c9e841e1d9f44
Parent:        d97583cfd395e5e31888558361ae9467cea60260
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 15 12:44:42 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 15 12:44:42 2013 +0200

activation: check for open count with a timeout before removal/deactivation of an LV

This patch reinstates the lv_info call to check for open count of
the LV we're removing/deactivating - this was changed with commit 125712b
some time ago and we relied on the ioctl retry logic deeper in the libdm
while calling the exact 'remove' ioctl.

However, there are still some situations in which it's still required to
check for open count before we do any 'remove' actions - this mainly
applies to LVs which consist of several sub LVs, like it is for
virtual snapshot devices.

The commit 1146691 fixed the issue with ordering of actions during
virtual snapshot removal while the snapshot is still open. But
the check for the open status of the snapshot is still prone to
marking the snapshot as in use with an immediate exit even though
this could be a temporary asynchronous open only, most notably
because of udev and its WATCH udev rule with accompanying scans
for the event which is asynchronous. The situation where this crops
up most often is when we're closing the LV that was open for read-write
and then calling lvremove immediately.

This patch reinstates the original lv_info call for the open status
of the LV in the lv_check_not_in_use fn that gets called before
we do any LV removal/deactivation. In addition to original logic,
this patch adds its own retry loop with a delay (25x0.2 seconds)
besides the existing ioctl retry loop.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   51 ++++++++++++++++++++++++++++++----------------
 2 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 04be5f1..f5f0256 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Check for open count with a timeout before removal/deactivation of an LV.
   Report RAID images split with tracking as out-of-sync ("I").
   Improve parsing of snapshot lv segment.
   Add workaround for deactivation problem of opened virtual snapshot.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6948060..131a093 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -251,8 +251,8 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 {
 	return 0;
 }
-int lv_check_not_in_use(struct cmd_context *cmd __attribute__((unused)),
-			struct logical_volume *lv, struct lvinfo *info)
+int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+			struct lvinfo *info)
 {
         return 0;
 }
@@ -676,33 +676,48 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 	return r;
 }
 
-int lv_check_not_in_use(struct cmd_context *cmd __attribute__((unused)),
-			struct logical_volume *lv, struct lvinfo *info)
+#define OPEN_COUNT_CHECK_RETRIES 25
+#define OPEN_COUNT_CHECK_USLEEP_DELAY 200000
+
+int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+			struct lvinfo *info)
 {
+	unsigned int open_count_check_retries;
+
 	if (!info->exists)
 		return 1;
 
 	/* If sysfs is not used, use open_count information only. */
-	if (!*dm_sysfs_dir()) {
-		if (info->open_count) {
-			log_error("Logical volume %s/%s in use.",
+	if (dm_sysfs_dir()) {
+		if (dm_device_has_holders(info->major, info->minor)) {
+			log_error("Logical volume %s/%s is used by another device.",
 				  lv->vg->name, lv->name);
 			return 0;
 		}
 
-		return 1;
-	}
-
-	if (dm_device_has_holders(info->major, info->minor)) {
-		log_error("Logical volume %s/%s is used by another device.",
-			  lv->vg->name, lv->name);
-		return 0;
+		if (dm_device_has_mounted_fs(info->major, info->minor)) {
+			log_error("Logical volume %s/%s contains a filesystem in use.",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
 	}
 
-	if (dm_device_has_mounted_fs(info->major, info->minor)) {
-		log_error("Logical volume %s/%s contains a filesystem in use.",
-			  lv->vg->name, lv->name);
-		return 0;
+	open_count_check_retries = retry_deactivation() ? OPEN_COUNT_CHECK_RETRIES : 1;
+	while (open_count_check_retries--) {
+		if (info->open_count > 0) {
+			if (open_count_check_retries) {
+				usleep(OPEN_COUNT_CHECK_USLEEP_DELAY);
+				log_debug_activation("Retrying open_count check for %s/%s.",
+						     lv->vg->name, lv->name);
+				if (!lv_info(cmd, lv, 0, info, 1, 0))
+					return -1;
+				continue;
+			}
+			log_error("Logical volume %s/%s in use.",
+				  lv->vg->name, lv->name);
+			return 0;
+		} else
+			break;
 	}
 
 	return 1;


