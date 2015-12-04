From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Dec 2015 21:11:43 +0000 (UTC)
Subject: master - archiver: fix reporting for check_current_backup
Message-ID: <20151204211143.4F87860E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=748b8158b5bb7d986fb26f2462c4909f723214fc
Commit:        748b8158b5bb7d986fb26f2462c4909f723214fc
Parent:        8b16efd17c8341af719a407aafa010c3c3ad3353
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 4 22:04:14 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 4 22:10:30 2015 +0100

archiver: fix reporting for check_current_backup

It's getting a bit more complex here.

Basic idea behind is - check_current_backup() should not
log error when a user is using a read-only filesystem,
so e.g.  vgscan  will not report any error when it tries
to take missing backup.

We still have cases when error could be reported though,
e.g. the backup this would be a symbolic link, but these
are rather misconfiguration and unexpected case.
---
 lib/format_text/archiver.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 4f5ea25..04f9550 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -121,19 +121,20 @@ static int _archive(struct volume_group *vg, int compulsory)
 	}
 
 	if (!dm_create_dir(vg->cmd->archive_params->dir)) {
-		/* FIXME: !compulsory logs error here */
-		log_error("Cannot create archiving directory %s.",
-			  vg->cmd->archive_params->dir);
-		return compulsory ? 0 : 1;
+		if (compulsory)
+			return_0;
+		return 1;
 	}
 
 	/* Trap a read-only file system */
 	if ((access(vg->cmd->archive_params->dir, R_OK | W_OK | X_OK) == -1) &&
 	    (errno == EROFS)) {
-		/* FIXME: !compulsory logs error here */
-		log_error("Cannot archive volume group metadata for %s to read-only filesystem.",
-			  vg->name);
-		return compulsory ? 0 : 1;
+		if (compulsory) {
+			log_error("Cannot archive volume group metadata for %s to read-only filesystem.",
+				  vg->name);
+			return 0;
+		}
+		return 1;
 	}
 
 	log_verbose("Archiving volume group \"%s\" metadata (seqno %u).", vg->name,
@@ -249,8 +250,8 @@ int backup_locally(struct volume_group *vg)
 	/* Trap a read-only file system */
 	if ((access(vg->cmd->backup_params->dir, R_OK | W_OK | X_OK) == -1) &&
 	    (errno == EROFS)) {
-		log_warn("WARNING: Cannot backup of volume group %s metadata to read-only fs.",
-			  vg->name);
+		/* Will take a backup next time when FS is writable */
+		log_debug("Skipping backup of volume group on read-only filesystem.");
 		return 0;
 	}
 
@@ -493,6 +494,9 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 
 /*
  * Update backup (and archive) if they're out-of-date or don't exist.
+ *
+ * This function is not supposed to log_error
+ * when the filesystem with archive/backup dir is read-only.
  */
 void check_current_backup(struct volume_group *vg)
 {


