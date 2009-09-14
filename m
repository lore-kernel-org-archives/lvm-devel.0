From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Sep 2009 12:35:04 -0400
Subject: [PATCH 2/2] Use vg_is_exported(vg) macro everywhere.
In-Reply-To: <1252946104-4824-2-git-send-email-dwysocha@redhat.com>
References: <1252946104-4824-1-git-send-email-dwysocha@redhat.com>
	<1252946104-4824-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1252946104-4824-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is all just cleanup and no other patch depends on it.
Replace explicit dereference and check with vg_is_exported().
Update a few copyrights and remove unnecessary whitespace.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c        |    2 +-
 lib/display/display.c       |    2 +-
 lib/format1/import-export.c |    6 +++---
 lib/format_text/archiver.c  |    2 +-
 lib/report/report.c         |    2 +-
 tools/vgchange.c            |    4 ++--
 tools/vgimport.c            |    4 ++--
 tools/vgscan.c              |    4 ++--
 8 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9ad61a2..74b66e4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -821,7 +821,7 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 	char uuid_primary[64] __attribute((aligned(8)));
 	char uuid_new[64] __attribute((aligned(8)));
 	int use_new = 0;
-	
+
 	/* Pre-existing VG takes precedence. Unexported VG takes precedence. */
 	if (primary_vginfo) {
 		if (!id_write_format((const struct id *)vgid, uuid_new, sizeof(uuid_new)))
diff --git a/lib/display/display.c b/lib/display/display.c
index 6e280b1..058b084 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -597,7 +597,7 @@ void vgdisplay_full(const struct volume_group *vg)
 		  access_str == LVM_WRITE ? "write" : "",
 		  access_str == 0 ? "error" : "");
 	log_print("VG Status             %s%sresizable",
-		  vg->status & EXPORTED_VG ? "exported/" : "",
+		  vg_is_exported(vg) ? "exported/" : "",
 		  vg->status & RESIZEABLE_VG ? "" : "NOT ");
 	/* vg number not part of LVM2 design
 	   log_print ("VG #                  %u\n", vg->vg_number);
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 4d0e5c5..245e1cf 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -160,7 +160,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute((unused))
 		strncpy((char *)pvd->system_id, vg->system_id, sizeof(pvd->system_id));
 
 	/* Is VG already exported or being exported? */
-	if (vg && (vg->status & EXPORTED_VG)) {
+	if (vg && vg_is_exported(EXPORTED_VG)) {
 		/* Does system_id need setting? */
 		if (!*vg->system_id ||
 		    strncmp(vg->system_id, EXPORTED_TAG,
@@ -178,7 +178,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute((unused))
 	}
 
 	/* Is VG being imported? */
-	if (vg && !(vg->status & EXPORTED_VG) && *vg->system_id &&
+	if (vg && !vg_is_exported(vg) && *vg->system_id &&
 	    !strncmp(vg->system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
 		if (!_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
 			return_0;
@@ -275,7 +275,7 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
 	if (vg->status & SHARED)
 		vgd->vg_access |= VG_SHARED;
 
-	if (vg->status & EXPORTED_VG)
+	if (vg_is_exported(vg))
 		vgd->vg_status |= VG_EXPORTED;
 
 	if (vg->status & RESIZEABLE_VG)
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index a3fd4bd..78aea95 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -415,7 +415,7 @@ void check_current_backup(struct volume_group *vg)
 	struct volume_group *vg_backup;
 	int old_suppress;
 
-	if (vg->status & EXPORTED_VG)
+	if (vg_is_exported(vg))
 		return;
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
diff --git a/lib/report/report.c b/lib/report/report.c
index bfa4b76..a6569b4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -434,7 +434,7 @@ static int _vgstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 	else
 		repstr[1] = '-';
 
-	if (vg->status & EXPORTED_VG)
+	if (vg_is_exported(vg))
 		repstr[2] = 'x';
 	else
 		repstr[2] = '-';
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 19c3eb7..75b26e8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -446,7 +446,7 @@ static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
 
 	if (!vg_refresh_visible(cmd, vg))
 		return ECMD_FAILED;
-	
+
 	return ECMD_PROCESSED;
 }
 
@@ -459,7 +459,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
-	if (vg_status(vg) & EXPORTED_VG) {
+	if (vg_is_exported(EXPORTED_VG)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 864a700..5161b62 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,7 +26,7 @@ static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
 	if (vg_read_error(vg))
 		goto error;
 
-	if (!(vg_status(vg) & EXPORTED_VG)) {
+	if (!vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
 		goto error;
 	}
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 769c5cf..a7aef5f 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -23,7 +23,7 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 
 	log_print("Found %svolume group \"%s\" using metadata type %s",
-		  (vg_status(vg) & EXPORTED_VG) ? "exported " : "", vg_name,
+		  vg_is_exported(vg) ? "exported " : "", vg_name,
 		  vg->fid->fmt->name);
 
 	check_current_backup(vg);
-- 
1.6.0.6


