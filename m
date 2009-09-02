From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:39:07 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090902213907.18302.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:39:07

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgconvert.c 

Log message:
	Rename internal library function vg_remove to vg_remove_mdas.
	
	Later patches should consolidate the vgremove / vgreduce functions but for
	now let's clarify what vg_remove actually does by changing the name.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.279&r2=1.280
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/lib/metadata/metadata-exported.h	2009/07/30 17:45:29	1.107
+++ LVM2/lib/metadata/metadata-exported.h	2009/09/02 21:39:07	1.108
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -441,7 +441,7 @@
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
-int vg_remove(struct volume_group *vg);
+int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_single(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
--- LVM2/lib/metadata/metadata.c	2009/08/20 07:03:02	1.279
+++ LVM2/lib/metadata/metadata.c	2009/09/02 21:39:07	1.280
@@ -502,8 +502,8 @@
 		return 0;
 	}
 
-	if (!vg_remove(vg)) {
-		log_error("vg_remove %s failed", vg->name);
+	if (!vg_remove_mdas(vg)) {
+		log_error("vg_remove_mdas %s failed", vg->name);
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return 0;
 	}
@@ -1676,7 +1676,7 @@
 	return NULL;
 }
 
-int vg_remove(struct volume_group *vg)
+int vg_remove_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda;
 
--- LVM2/tools/vgconvert.c	2009/07/30 17:45:30	1.37
+++ LVM2/tools/vgconvert.c	2009/09/02 21:39:07	1.38
@@ -167,7 +167,7 @@
 	}
 
 	log_verbose("Deleting existing metadata for VG %s", vg_name);
-	if (!vg_remove(vg)) {
+	if (!vg_remove_mdas(vg)) {
 		log_error("Removal of existing metadata for %s failed.",
 			  vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair "


