From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Sep 2011 09:54:21 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110914095421.1606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-14 09:54:21

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Add missing underscores to local static functions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/lib/metadata/mirror.c	2011/09/14 04:10:26	1.168
+++ LVM2/lib/metadata/mirror.c	2011/09/14 09:54:21	1.169
@@ -81,7 +81,7 @@
  *
  * Returns: 1 if available, 0 otherwise
  */
-static int cluster_mirror_is_available(struct logical_volume *lv)
+static int _cluster_mirror_is_available(struct logical_volume *lv)
 {
        unsigned attr = 0;
        struct cmd_context *cmd = lv->vg->cmd;
@@ -1256,7 +1256,7 @@
 	return 1;
 }
 
-static int get_mirror_fault_policy(struct cmd_context *cmd __attribute__((unused)),
+static int _get_mirror_fault_policy(struct cmd_context *cmd __attribute__((unused)),
 				   int log_policy)
 {
 	const char *policy;
@@ -1287,14 +1287,14 @@
 	return MIRROR_REMOVE;
 }
 
-static int get_mirror_log_fault_policy(struct cmd_context *cmd)
+static int _get_mirror_log_fault_policy(struct cmd_context *cmd)
 {
-	return get_mirror_fault_policy(cmd, 1);
+	return _get_mirror_fault_policy(cmd, 1);
 }
 
-static int get_mirror_device_fault_policy(struct cmd_context *cmd)
+static int _get_mirror_device_fault_policy(struct cmd_context *cmd)
 {
-	return get_mirror_fault_policy(cmd, 0);
+	return _get_mirror_fault_policy(cmd, 0);
 }
 
 /*
@@ -1310,7 +1310,7 @@
  *
  * Returns: 0 on failure, 1 on reconfig, -1 if no reconfig done
  */
-static int replace_mirror_images(struct lv_segment *mirrored_seg,
+static int _replace_mirror_images(struct lv_segment *mirrored_seg,
 				 uint32_t num_mirrors,
 				 int log_policy, int in_sync)
 {
@@ -1381,10 +1381,10 @@
 	log_warn("WARNING: Bad device removed from mirror volume, %s/%s",
 		  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 
-	log_policy = get_mirror_log_fault_policy(mirrored_seg->lv->vg->cmd);
-	dev_policy = get_mirror_device_fault_policy(mirrored_seg->lv->vg->cmd);
+	log_policy = _get_mirror_log_fault_policy(mirrored_seg->lv->vg->cmd);
+	dev_policy = _get_mirror_device_fault_policy(mirrored_seg->lv->vg->cmd);
 
-	r = replace_mirror_images(mirrored_seg,
+	r = _replace_mirror_images(mirrored_seg,
 				  (dev_policy != MIRROR_REMOVE) ?
 				  old_num_mirrors : num_mirrors,
 				  log_policy, in_sync);
@@ -2103,7 +2103,7 @@
 
 	if (vg_is_clustered(lv->vg)) {
 		/* FIXME: review check of lv_is_active_remotely */
-		if (!cluster_mirror_is_available(lv)) {
+		if (!_cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;
 		}


