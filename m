From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Apr 2019 15:39:02 -0400
Subject: master - pvcreate: call label scan prior to pvcreate_each_device
Message-ID: <201904301939.x3UJd2pL015811@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=366c1ac15b853fe3efc95472c569efc575f1237f
Commit:        366c1ac15b853fe3efc95472c569efc575f1237f
Parent:        6d0f09f4783061054152ae0013d7ebfad949c343
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 30 14:10:27 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 30 14:10:27 2019 -0500

pvcreate: call label scan prior to pvcreate_each_device

and don't call it from inside pvcreate_each_device.
This avoids having to repeat it for users of
pvcreate_each_device (pvcreate/pvremove/vgcreate/vgextend.)
---
 tools/pvcreate.c |    5 +++--
 tools/pvremove.c |    2 ++
 tools/toollib.c  |   10 ++--------
 tools/vgextend.c |    4 +++-
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 10d1a37..5b59a79 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -145,6 +145,8 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
+	lvmcache_label_scan(cmd);
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -152,9 +154,8 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!pvcreate_each_device(cmd, handle, &pp))
 		ret = ECMD_FAILED;
-	else {
+	else
 		ret = ECMD_PROCESSED;
-	}
 
 	destroy_processing_handle(cmd, handle);
 	return ret;
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 4ad1f42..2dfdbd0 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -45,6 +45,8 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
+	lvmcache_label_scan(cmd);
+
 	/* When forcibly clearing a PV we don't care about a VG lock. */
 	if (pp.force == DONT_PROMPT_OVERRIDE)
 		cmd->lockd_vg_disable = 1;
diff --git a/tools/toollib.c b/tools/toollib.c
index b8be826..b352839 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2243,7 +2243,8 @@ int process_each_vg(struct cmd_context *cmd,
 	 * Scan all devices to populate lvmcache with initial
 	 * list of PVs and VGs.
 	 */
-	lvmcache_label_scan(cmd);
+	if (!(read_flags & PROCESS_SKIP_SCAN))
+		lvmcache_label_scan(cmd);
 
 	/*
 	 * A list of all VGs on the system is needed when:
@@ -5327,13 +5328,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	}
 
 	/*
-	 * Scan before calling process_each_pv so we can set up the PV args
-	 * first.  We can then skip the scan that would normally occur at the
-	 * beginning of process_each_pv.
-	 */
-	lvmcache_label_scan(cmd);
-
-	/*
 	 * Translate arg names into struct device's.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices)
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 02da3a8..785be3f 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -162,6 +162,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
+	lvmcache_label_scan(cmd);
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -185,7 +187,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	handle->custom_handle = &vp;
 
 	ret = process_each_vg(cmd, 0, NULL, vg_name, NULL,
-			      READ_FOR_UPDATE, 0, handle,
+			      READ_FOR_UPDATE | PROCESS_SKIP_SCAN, 0, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
 	destroy_processing_handle(cmd, handle);


