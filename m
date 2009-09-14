From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Sep 2009 19:44:18 -0000
Subject: LVM2 lib/cache/lvmcache.c lib/display/display. ...
Message-ID: <20090914194418.7366.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-14 19:44:16

Modified files:
	lib/cache      : lvmcache.c 
	lib/display    : display.c 
	lib/format1    : import-export.c 
	lib/format_text: archiver.c 
	lib/report     : report.c 
	tools          : vgchange.c vgimport.c vgscan.c 

Log message:
	Use vg_is_exported(vg) macro everywhere.
	
	This patch is all just cleanup and no other patch depends on it.
	Replace explicit dereference and check with vg_is_exported().
	Update a few copyrights and remove unnecessary whitespace.
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/lib/cache/lvmcache.c	2009/09/02 21:34:11	1.67
+++ LVM2/lib/cache/lvmcache.c	2009/09/14 19:44:15	1.68
@@ -821,7 +821,7 @@
 	char uuid_primary[64] __attribute((aligned(8)));
 	char uuid_new[64] __attribute((aligned(8)));
 	int use_new = 0;
-	
+
 	/* Pre-existing VG takes precedence. Unexported VG takes precedence. */
 	if (primary_vginfo) {
 		if (!id_write_format((const struct id *)vgid, uuid_new, sizeof(uuid_new)))
--- LVM2/lib/display/display.c	2009/07/27 10:18:31	1.99
+++ LVM2/lib/display/display.c	2009/09/14 19:44:15	1.100
@@ -597,7 +597,7 @@
 		  access_str == LVM_WRITE ? "write" : "",
 		  access_str == 0 ? "error" : "");
 	log_print("VG Status             %s%sresizable",
-		  vg->status & EXPORTED_VG ? "exported/" : "",
+		  vg_is_exported(vg) ? "exported/" : "",
 		  vg->status & RESIZEABLE_VG ? "" : "NOT ");
 	/* vg number not part of LVM2 design
 	   log_print ("VG #                  %u\n", vg->vg_number);
--- LVM2/lib/format1/import-export.c	2009/07/15 20:02:46	1.107
+++ LVM2/lib/format1/import-export.c	2009/09/14 19:44:15	1.108
@@ -160,7 +160,7 @@
 		strncpy((char *)pvd->system_id, vg->system_id, sizeof(pvd->system_id));
 
 	/* Is VG already exported or being exported? */
-	if (vg && (vg->status & EXPORTED_VG)) {
+	if (vg && vg_is_exported(vg)) {
 		/* Does system_id need setting? */
 		if (!*vg->system_id ||
 		    strncmp(vg->system_id, EXPORTED_TAG,
@@ -178,7 +178,7 @@
 	}
 
 	/* Is VG being imported? */
-	if (vg && !(vg->status & EXPORTED_VG) && *vg->system_id &&
+	if (vg && !vg_is_exported(vg) && *vg->system_id &&
 	    !strncmp(vg->system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
 		if (!_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
 			return_0;
@@ -275,7 +275,7 @@
 	if (vg->status & SHARED)
 		vgd->vg_access |= VG_SHARED;
 
-	if (vg->status & EXPORTED_VG)
+	if (vg_is_exported(vg))
 		vgd->vg_status |= VG_EXPORTED;
 
 	if (vg->status & RESIZEABLE_VG)
--- LVM2/lib/format_text/archiver.c	2009/07/30 17:45:29	1.28
+++ LVM2/lib/format_text/archiver.c	2009/09/14 19:44:16	1.29
@@ -415,7 +415,7 @@
 	struct volume_group *vg_backup;
 	int old_suppress;
 
-	if (vg->status & EXPORTED_VG)
+	if (vg_is_exported(vg))
 		return;
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
--- LVM2/lib/report/report.c	2009/07/26 12:41:09	1.100
+++ LVM2/lib/report/report.c	2009/09/14 19:44:16	1.101
@@ -434,7 +434,7 @@
 	else
 		repstr[1] = '-';
 
-	if (vg->status & EXPORTED_VG)
+	if (vg_is_exported(vg))
 		repstr[2] = 'x';
 	else
 		repstr[2] = '-';
--- LVM2/tools/vgchange.c	2009/07/15 05:49:48	1.82
+++ LVM2/tools/vgchange.c	2009/09/14 19:44:16	1.83
@@ -446,7 +446,7 @@
 
 	if (!vg_refresh_visible(cmd, vg))
 		return ECMD_FAILED;
-	
+
 	return ECMD_PROCESSED;
 }
 
@@ -459,7 +459,7 @@
 	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
-	if (vg_status(vg) & EXPORTED_VG) {
+	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/vgimport.c	2009/07/01 17:00:52	1.20
+++ LVM2/tools/vgimport.c	2009/09/14 19:44:16	1.21
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,7 +26,7 @@
 	if (vg_read_error(vg))
 		goto error;
 
-	if (!(vg_status(vg) & EXPORTED_VG)) {
+	if (!vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
 		goto error;
 	}
--- LVM2/tools/vgscan.c	2009/07/01 17:00:52	1.34
+++ LVM2/tools/vgscan.c	2009/09/14 19:44:16	1.35
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -23,7 +23,7 @@
 		return ECMD_FAILED;
 
 	log_print("Found %svolume group \"%s\" using metadata type %s",
-		  (vg_status(vg) & EXPORTED_VG) ? "exported " : "", vg_name,
+		  vg_is_exported(vg) ? "exported " : "", vg_name,
 		  vg->fid->fmt->name);
 
 	check_current_backup(vg);


