From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:22:24 +0000 (UTC)
Subject: master - archiver: inital change toward proper logging
Message-ID: <20151203172224.DE85D60C8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f40b3ba1e904f6c6a3e1264e6d734f558ec731d9
Commit:        f40b3ba1e904f6c6a3e1264e6d734f558ec731d9
Parent:        20acc66a237429d81b699b56be57d4d043362098
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 3 17:32:47 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 3 18:01:45 2015 +0100

archiver: inital change toward proper logging

We have to modes of  'archive()' usage -
1. compulsory - fail stops command and user may try '-An' option
to do a command.

2. non-compulsory - some fails in archiving are ignorable (i.e.
read-only filesystem where archive dir is located).

Those 2 cases needs to be properly handle - i.e. the non-compulsory
logging should not be tampering  error logging message production.

So more work here is needed
---
 lib/format_text/archiver.c |   64 +++++++++++++++++++++++++------------------
 1 files changed, 37 insertions(+), 27 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e3d3d57..4f5ea25 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -98,20 +98,10 @@ static char *_build_desc(struct dm_pool *mem, const char *line, int before)
 	return buffer;
 }
 
-static int __archive(struct volume_group *vg)
+static int _archive(struct volume_group *vg, int compulsory)
 {
 	char *desc;
 
-	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 1)))
-		return_0;
-
-	return archive_vg(vg, vg->cmd->archive_params->dir, desc,
-			  vg->cmd->archive_params->keep_days,
-			  vg->cmd->archive_params->keep_number);
-}
-
-int archive(struct volume_group *vg)
-{
 	/* Don't archive orphan VGs. */
 	if (is_orphan_vg(vg->name))
 		return 1;
@@ -130,27 +120,43 @@ int archive(struct volume_group *vg)
 		return 1;
 	}
 
-	if (!dm_create_dir(vg->cmd->archive_params->dir))
-		return 0;
+	if (!dm_create_dir(vg->cmd->archive_params->dir)) {
+		/* FIXME: !compulsory logs error here */
+		log_error("Cannot create archiving directory %s.",
+			  vg->cmd->archive_params->dir);
+		return compulsory ? 0 : 1;
+	}
 
 	/* Trap a read-only file system */
 	if ((access(vg->cmd->archive_params->dir, R_OK | W_OK | X_OK) == -1) &&
-	     (errno == EROFS))
-		return 0;
+	    (errno == EROFS)) {
+		/* FIXME: !compulsory logs error here */
+		log_error("Cannot archive volume group metadata for %s to read-only filesystem.",
+			  vg->name);
+		return compulsory ? 0 : 1;
+	}
 
 	log_verbose("Archiving volume group \"%s\" metadata (seqno %u).", vg->name,
 		    vg->seqno);
-	if (!__archive(vg)) {
-		log_error("Volume group \"%s\" metadata archive failed.",
-			  vg->name);
-		return 0;
-	}
+
+	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 1)))
+		return_0;
+
+	if (!archive_vg(vg, vg->cmd->archive_params->dir, desc,
+			vg->cmd->archive_params->keep_days,
+			vg->cmd->archive_params->keep_number))
+		return_0;
 
 	vg->status |= ARCHIVED_VG;
 
 	return 1;
 }
 
+int archive(struct volume_group *vg)
+{
+	return _archive(vg, 1);
+}
+
 int archive_display(struct cmd_context *cmd, const char *vg_name)
 {
 	int r1, r2;
@@ -207,7 +213,7 @@ void backup_enable(struct cmd_context *cmd, int flag)
 	cmd->backup_params->enabled = flag;
 }
 
-static int __backup(struct volume_group *vg)
+static int _backup(struct volume_group *vg)
 {
 	char name[PATH_MAX];
 	char *desc;
@@ -242,10 +248,13 @@ int backup_locally(struct volume_group *vg)
 
 	/* Trap a read-only file system */
 	if ((access(vg->cmd->backup_params->dir, R_OK | W_OK | X_OK) == -1) &&
-	    (errno == EROFS))
+	    (errno == EROFS)) {
+		log_warn("WARNING: Cannot backup of volume group %s metadata to read-only fs.",
+			  vg->name);
 		return 0;
+	}
 
-	if (!__backup(vg)) {
+	if (!_backup(vg)) {
 		log_error("Backup of volume group %s metadata failed.",
 			  vg->name);
 		return 0;
@@ -500,8 +509,9 @@ void check_current_backup(struct volume_group *vg)
 		return;
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
-			 vg->cmd->backup_params->dir, vg->name) < 0) {
-		log_debug("Failed to generate backup filename.");
+			vg->cmd->backup_params->dir, vg->name) < 0) {
+		log_warn("WARNING: Failed to generate backup pathname %s/%s.",
+			 vg->cmd->backup_params->dir, vg->name);
 		return;
 	}
 
@@ -517,11 +527,11 @@ void check_current_backup(struct volume_group *vg)
 	log_suppress(old_suppress);
 
 	if (vg_backup) {
-		if (!archive(vg_backup))
+		if (!_archive(vg_backup, 0))
 			stack;
 		release_vg(vg_backup);
 	}
-	if (!archive(vg))
+	if (!_archive(vg, 0))
 		stack;
 	if (!backup_locally(vg))
 		stack;


