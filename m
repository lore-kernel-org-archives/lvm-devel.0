From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 Aug 2007 19:09:50 -0000
Subject: LVM2/tools vgrename.c
Message-ID: <20070831190950.4059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-31 19:09:50

Modified files:
	tools          : vgrename.c 

Log message:
	prepare to move guts of vgrename into library function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/tools/vgrename.c	2007/08/20 20:55:30	1.45
+++ LVM2/tools/vgrename.c	2007/08/31 19:09:49	1.46
@@ -15,7 +15,8 @@
 
 #include "tools.h"
 
-int vgrename(struct cmd_context *cmd, int argc, char **argv)
+static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
+			  const char *new_vg_path)
 {
 	char *dev_dir;
 	unsigned length;
@@ -30,13 +31,8 @@
 	char old_path[NAME_LEN], new_path[NAME_LEN];
 	struct volume_group *vg_old, *vg_new;
 
-	if (argc != 2) {
-		log_error("Old and new volume group names need specifying");
-		return EINVALID_CMD_LINE;
-	}
-
-	vg_name_old = skip_dev_dir(cmd, argv[0], NULL);
-	vg_name_new = skip_dev_dir(cmd, argv[1], NULL);
+	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
+	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
 
 	dev_dir = cmd->dev_dir;
 	length = strlen(dev_dir);
@@ -45,18 +41,18 @@
 	if (strlen(vg_name_new) > NAME_LEN - length - 2) {
 		log_error("New volume group path exceeds maximum length "
 			  "of %d!", NAME_LEN - length - 2);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!validate_vg_name(cmd, vg_name_new)) {
 		log_error("New volume group name \"%s\" is invalid",
 			  vg_name_new);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!strcmp(vg_name_old, vg_name_new)) {
 		log_error("Old and new volume group names must differ");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
@@ -64,7 +60,7 @@
 	/* Avoid duplicates */
 	if (!(vgids = get_vgids(cmd, 0)) || list_empty(vgids)) {
 		log_error("No complete volume groups found");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	list_iterate_items(sl, vgids) {
@@ -75,7 +71,7 @@
 			if (match) {
 				log_error("Found more than one VG called %s. "
 					  "Please supply VG uuid.", vg_name_old);
-				return ECMD_FAILED;
+				return 0;
 			}
 			match = 1;
 		}
@@ -92,19 +88,19 @@
 
 	if (!lock_vol(cmd, vg_name_old, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vg_name_old);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!(vg_old = vg_read(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
 		log_error("Volume group %s %s%s%snot found.", vg_name_old,
 		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
 		unlock_vg(cmd, vg_name_old);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!vg_check_status(vg_old, CLUSTERED | LVM_WRITE)) {
 		unlock_vg(cmd, vg_name_old);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/* Don't return failure for EXPORTED_VG */
@@ -115,7 +111,7 @@
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);
 		/* FIXME Remove this restriction */
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
@@ -123,7 +119,7 @@
 	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE | LCK_NONBLOCK)) {
 		unlock_vg(cmd, vg_name_old);
 		log_error("Can't get lock for %s", vg_name_new);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	consistent = 0;
@@ -173,11 +169,24 @@
         persistent_filter_wipe(cmd->filter);
         lvmcache_destroy();
 
-	return ECMD_PROCESSED;
+	return 1;
 
       error:
 	unlock_vg(cmd, vg_name_new);
 	unlock_vg(cmd, vg_name_old);
-	return ECMD_FAILED;
+	return 0;
+}
+
+int vgrename(struct cmd_context *cmd, int argc, char **argv)
+{
+	if (argc != 2) {
+		log_error("Old and new volume group names need specifying");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!vg_rename_path(cmd, argv[0], argv[1]))
+		return ECMD_FAILED;
+	
+	return ECMD_PROCESSED;
 }
 


