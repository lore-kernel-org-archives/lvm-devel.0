From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 13 Apr 2010 17:04:57 +0200
Subject: [PATCH] Allow VGs with active LVs to be renamed
Message-ID: <4BC48819.5060203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch removes the restriction for a VG rename with active LVs and it also contains
a little cleanup for vgrename code (part of which is a fix for left-over lock when we
failed to get the old VG).

Peter
---

 tools/vgrename.c |   42 +++++++++++++++++-------------------------
 1 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index 799dcb2..3c383fb 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
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
 
@@ -29,18 +29,11 @@ static struct volume_group *vg_rename_old(struct cmd_context *cmd,
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
 
@@ -82,7 +75,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	dev_dir = cmd->dev_dir;
 
 	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
-		return 0;
+		return_0;
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
@@ -119,22 +112,23 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
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
@@ -170,8 +164,6 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		}
 	}
 
-/******* FIXME Rename any active LVs! *****/
-
 	backup(vg);
 	backup_remove(cmd, vg_name_old);
 


