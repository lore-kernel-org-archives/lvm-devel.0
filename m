From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:29:23 -0000
Subject: LVM2/tools vgrename.c
Message-ID: <20090902212923.13584.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:29:23

Modified files:
	tools          : vgrename.c 

Log message:
	Refactor vgrename into vg_rename_old and vg_rename_new.
	
	Should be no functional change.
	Will allow us to reorder lock obtaining if needed.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/tools/vgrename.c	2009/07/07 01:18:35	1.65
+++ LVM2/tools/vgrename.c	2009/09/02 21:29:23	1.66
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -15,6 +15,52 @@
 
 #include "tools.h"
 
+static struct volume_group *vg_rename_old(struct cmd_context *cmd,
+					  const char *vg_name_old,
+					  const char *vgid)
+{
+	struct volume_group *vg;
+
+	/* FIXME we used to print an error about EXPORTED, but proceeded
+	   nevertheless. */
+	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
+	if (vg_read_error(vg)) {
+		vg_release(vg);
+		return_NULL;
+	}
+
+	if (lvs_in_vg_activated_by_uuid_only(vg)) {
+		unlock_and_release_vg(cmd, vg, vg_name_old);
+		log_error("Volume group \"%s\" still has active LVs",
+			  vg_name_old);
+		/* FIXME Remove this restriction */
+		return NULL;
+	}
+	return vg;
+}
+
+static int vg_rename_new(struct cmd_context *cmd,
+			 const char *vg_name_new)
+{
+	int rc;
+
+	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
+
+	rc = vg_lock_newname(cmd, vg_name_new);
+
+	if (rc == FAILED_LOCKING) {
+		log_error("Can't get lock for %s", vg_name_new);
+		return 0;
+	}
+
+	if (rc == FAILED_EXIST) {
+		log_error("New volume group \"%s\" already exists",
+			  vg_name_new);
+		return 0;
+	}
+	return 1;
+}
+
 static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 			  const char *new_vg_path)
 {
@@ -70,35 +116,11 @@
 	} else
 		vgid = NULL;
 
-	/* FIXME we used to print an error about EXPORTED, but proceeded
-	   nevertheless. */
-	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
-	if (vg_read_error(vg)) {
-		vg_release(vg);
-		return_0;
-	}
-
-	if (lvs_in_vg_activated_by_uuid_only(vg)) {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		log_error("Volume group \"%s\" still has active LVs",
-			  vg_name_old);
-		/* FIXME Remove this restriction */
+	vg = vg_rename_old(cmd, vg_name_old, vgid);
+	if (!vg)
 		return 0;
-	}
-
-	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
-
-	rc = vg_lock_newname(cmd, vg_name_new);
 
-	if (rc == FAILED_LOCKING) {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		log_error("Can't get lock for %s", vg_name_new);
-		return 0;
-	}
-
-	if (rc == FAILED_EXIST) {
-		log_error("New volume group \"%s\" already exists",
-			  vg_name_new);
+	if (!vg_rename_new(cmd, vg_name_new)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
 		return 0;
 	}
@@ -168,7 +190,7 @@
 
 	if (!vg_rename_path(cmd, argv[0], argv[1]))
 		return ECMD_FAILED;
-	
+
 	return ECMD_PROCESSED;
 }
 


