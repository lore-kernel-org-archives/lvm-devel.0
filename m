From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Apr 2009 17:33:17 +0200
Subject: [PATCH v3] fix clvmd metadata backup
In-Reply-To: <49DF2C8F.6040005@redhat.com>
References: <49DF2C8F.6040005@redhat.com>
Message-ID: <49EDE73D.1020003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix remote metadata backup for clvmd

Run backup of metadata on remote nodes in the
same place like local node - when calling backup().

Introduce backup_locally() which calls only
local backup if needed.

Remote backup is now trigerred by LCK_VG_BACKUP flag
combination (special VG lock).

This lock type will call check_current_backup()
(including backup_locally() call) and updates
metadata on all nodes.

(Patch fixes non-functional remote backup,
current call during VG lock never triggers.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    6 +++++-
 lib/format_text/archiver.c    |   13 +++++++++++--
 lib/format_text/archiver.h    |    1 +
 lib/locking/cluster_locking.c |   15 +++++++--------
 lib/locking/locking.h         |    3 +++
 5 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 12bf935..dffff21 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -159,7 +159,11 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		break;
 
 	case CLVMD_CMD_VG_BACKUP:
-		lvm_do_backup(&args[2]);
+		/*
+		 * Do not run backup on local node, caller should do that.
+		 */
+		if (!client)
+			lvm_do_backup(&args[2]);
 		break;
 
 	default:
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 61d2441..5362adb 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -20,6 +20,7 @@
 #include "lvm-string.h"
 #include "lvmcache.h"
 #include "toolcontext.h"
+#include "locking.h"
 
 #include <unistd.h>
 
@@ -202,7 +203,7 @@ static int __backup(struct volume_group *vg)
 	return backup_to_file(name, desc, vg);
 }
 
-int backup(struct volume_group *vg)
+int backup_locally(struct volume_group *vg)
 {
 	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
 		log_warn("WARNING: This metadata update is NOT backed up");
@@ -231,6 +232,14 @@ int backup(struct volume_group *vg)
 	return 1;
 }
 
+int backup(struct volume_group *vg)
+{
+	if (vg_is_clustered(vg))
+		remote_backup_metadata(vg);
+
+	return backup_locally(vg);
+}
+
 int backup_remove(struct cmd_context *cmd, const char *vg_name)
 {
 	char path[PATH_MAX];
@@ -426,5 +435,5 @@ void check_current_backup(struct volume_group *vg)
 		vg_release(vg_backup);
 	}
 	archive(vg);
-	backup(vg);
+	backup_locally(vg);
 }
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index eb58ae9..7346f93 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -46,6 +46,7 @@ void backup_exit(struct cmd_context *cmd);
 
 void backup_enable(struct cmd_context *cmd, int flag);
 int backup(struct volume_group *vg);
+int backup_locally(struct volume_group *vg);
 int backup_remove(struct cmd_context *cmd, const char *vg_name);
 
 struct volume_group *backup_read_vg(struct cmd_context *cmd,
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 1d4d867..1f0e841 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -385,6 +385,13 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		if (flags == LCK_VG_BACKUP) {
+			log_very_verbose("Requesting backup of VG metadata for %s",
+					 resource);
+			return _lock_for_cluster(CLVMD_CMD_VG_BACKUP,
+						 LCK_CLUSTER_VG, resource);
+		}
+
 		/* If the VG name is empty then lock the unused PVs */
 		if (*resource == '#' || (flags & LCK_CACHE))
 			dm_snprintf(lockname, sizeof(lockname), "P_%s",
@@ -436,14 +443,6 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 		return 0;
 	}
 
-	/* If we are unlocking a clustered VG, then trigger remote metadata backups */
-	if (clvmd_cmd == CLVMD_CMD_LOCK_VG &&
-	    ((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
-	    (flags & LCK_CLUSTER_VG)) {
-		log_very_verbose("Requesing backup of VG metadata for %s", resource);
-		_lock_for_cluster(CLVMD_CMD_VG_BACKUP, LCK_CLUSTER_VG, resource);
-	}
-
 	log_very_verbose("Locking %s %s %s %s%s%s%s (0x%x)", lock_scope, lockname,
 			 lock_type,
 			 flags & LCK_NONBLOCK ? "" : "B",
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 71122c3..ee7f5a1 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -101,6 +101,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
 #define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
+#define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL | LCK_NONBLOCK)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE | LCK_NONBLOCK)
@@ -131,6 +132,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
+#define remote_backup_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);



