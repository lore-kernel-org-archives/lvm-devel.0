From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:32:52 +0200
Subject: [PATCH 4/6] vg mempool: fix archiver code
Message-ID: <49D9BE34.4010308@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Properly release VG memory pool in archiver code.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/archive.c  |    2 +-
 lib/format_text/archiver.c |   13 +++++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 3e5b0c4..0077f14 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -326,7 +326,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	log_print("Description:\t%s", desc ? : "<No description>");
 	log_print("Backup Time:\t%s", ctime(&when));
 
-	dm_pool_free(cmd->mem, vg);
+	vg_release(vg);
 	tf->fmt->ops->destroy_instance(tf);
 }
 
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e221500..61d2441 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -326,6 +326,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file)
 {
 	struct volume_group *vg;
+	int r = 0;
 
 	/*
 	 * Read in the volume group from the text file.
@@ -336,10 +337,11 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 	/*
 	 * If PV is missing, there is already message from read above
 	 */
-	if (vg_missing_pv_count(vg))
-		return_0;
+	if (!vg_missing_pv_count(vg))
+		r = backup_restore_vg(cmd, vg);
 
-	return backup_restore_vg(cmd, vg);
+	vg_release(vg);
+	return r;
 }
 
 int backup_restore(struct cmd_context *cmd, const char *vg_name)
@@ -414,12 +416,15 @@ void check_current_backup(struct volume_group *vg)
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
 		log_suppress(old_suppress);
+		vg_release(vg_backup);
 		return;
 	}
 	log_suppress(old_suppress);
 
-	if (vg_backup)
+	if (vg_backup) {
 		archive(vg_backup);
+		vg_release(vg_backup);
+	}
 	archive(vg);
 	backup(vg);
 }



