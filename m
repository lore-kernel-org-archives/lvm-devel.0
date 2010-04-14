From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Apr 2010 13:03:08 -0000
Subject: LVM2 ./WHATS_NEW tools/vgrename.c
Message-ID: <20100414130308.16740.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-14 13:03:07

Modified files:
	.              : WHATS_NEW 
	tools          : vgrename.c 

Log message:
	Allow VGs with active LVs to be renamed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1518&r2=1.1519
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2010/04/14 13:01:38	1.1518
+++ LVM2/WHATS_NEW	2010/04/14 13:03:06	1.1519
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Allow VGs with active LVs to be renamed.
   Use UUIDs instead of names while processing event handlers.
   Only pass visible LVs to tools in cmdline VG name/tag expansions without -a.
   Use typedefs for toollib process_each functions.
--- LVM2/tools/vgrename.c	2010/03/16 16:57:05	1.71
+++ LVM2/tools/vgrename.c	2010/04/14 13:03:06	1.72
@@ -15,9 +15,9 @@
 
 #include "tools.h"
 
-static struct volume_group *vg_rename_old(struct cmd_context *cmd,
-					  const char *vg_name_old,
-					  const char *vgid)
+static struct volume_group *_get_old_vg_for_rename(struct cmd_context *cmd,
+						   const char *vg_name_old,
+						   const char *vgid)
 {
 	struct volume_group *vg;
 
@@ -29,18 +29,11 @@
 		return_NULL;
 	}
 
-	if (lvs_in_vg_activated(vg)) {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		log_error("Volume group \"%s\" still has active LVs",
-			  vg_name_old);
-		/* FIXME Remove this restriction */
-		return NULL;
-	}
 	return vg;
 }
 
-static int vg_rename_new(struct cmd_context *cmd,
-			 const char *vg_name_new)
+static int _lock_new_vg_for_rename(struct cmd_context *cmd,
+				   const char *vg_name_new)
 {
 	int rc;
 
@@ -82,7 +75,7 @@
 	dev_dir = cmd->dev_dir;
 
 	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
-		return 0;
+		return_0;
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
@@ -119,22 +112,23 @@
 		lock_vg_old_first = 0;
 
 	if (lock_vg_old_first) {
-		vg = vg_rename_old(cmd, vg_name_old, vgid);
+		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid);
 		if (!vg)
-			return 0;
+			return_0;
 
-		if (!vg_rename_new(cmd, vg_name_new)) {
+		if (!_lock_new_vg_for_rename(cmd, vg_name_new)) {
 			unlock_and_release_vg(cmd, vg, vg_name_old);
-			return 0;
+			return_0;
 		}
 	} else {
-		if (!vg_rename_new(cmd, vg_name_new)) {
-			return 0;
-		}
+		if (!_lock_new_vg_for_rename(cmd, vg_name_new))
+			return_0;
 
-		vg = vg_rename_old(cmd, vg_name_old, vgid);
-		if (!vg)
-			return 0;
+		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid);
+		if (!vg) {
+			unlock_vg(cmd, vg_name_new);
+			return_0;
+		}
 	}
 
 	if (!archive(vg))
@@ -170,8 +164,6 @@
 		}
 	}
 
-/******* FIXME Rename any active LVs! *****/
-
 	backup(vg);
 	backup_remove(cmd, vg_name_old);
 


