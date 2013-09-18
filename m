From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Sep 2013 10:53:58 +0000 (UTC)
Subject: master - vgconvert: Do not call lvmetad_vg_remove (path shared with vgcfgbackup).
Message-ID: <20130918105358.226C760D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3df50d822b8064c5536968556c466c50a9a3ace5
Commit:        3df50d822b8064c5536968556c466c50a9a3ace5
Parent:        054cf25b5f6a34de8886ba6293deee2b24720902
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 18 12:53:11 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 18 12:53:11 2013 +0200

vgconvert: Do not call lvmetad_vg_remove (path shared with vgcfgbackup).

---
 lib/format_text/archiver.c |    6 +++---
 lib/format_text/archiver.h |    2 +-
 tools/vgconvert.c          |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 752e93c..e3e7777 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -308,7 +308,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 }
 
 /* ORPHAN and VG locks held before calling this */
-int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
+int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop_lvmetad)
 {
 	struct pv_list *pvl;
 	struct format_instance *fid;
@@ -351,7 +351,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 	if (!vg_write(vg))
 		return_0;
 
-	if (lvmetad_active()) {
+	if (drop_lvmetad && lvmetad_active()) {
 		struct volume_group *vg_lvmetad = lvmetad_vg_lookup(cmd, vg->name, NULL);
 		if (vg_lvmetad) {
 			lvmetad_vg_remove(vg_lvmetad);
@@ -397,7 +397,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
-		r = backup_restore_vg(cmd, vg);
+		r = backup_restore_vg(cmd, vg, 1);
 	else
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index ddff687..bc756d5 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -51,7 +51,7 @@ int backup_remove(struct cmd_context *cmd, const char *vg_name);
 
 struct volume_group *backup_read_vg(struct cmd_context *cmd,
 				    const char *vg_name, const char *file);
-int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg);
+int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop_lvmetad);
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file, int force);
 int backup_restore(struct cmd_context *cmd, const char *vg_name, int force);
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index fbb1b4e..86e3097 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -184,7 +184,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
 		    cmd->fmt->name);
-	if (!backup_restore_vg(cmd, vg)) {
+	if (!backup_restore_vg(cmd, vg, 0)) {
 		log_error("Conversion failed for volume group %s.", vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair from "
 			  "archived metadata.");


