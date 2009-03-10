From: Milan Broz <mbroz@redhat.com>
Date: Tue, 10 Mar 2009 18:41:00 +0100
Subject: [PATCH 1/3] clvmd: fix remote metadata backup
Message-ID: <49B6A62C.3080709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix remote metadata backup for clvmd

Currently the remote metadata backup doesn't work,
because we added
	if (clvmd_cmd == CLVMD_CMD_LOCK_VG &&
	   ((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
           (flags & LCK_CLUSTER_VG)) {
		... call the remote backup command

LCK_CLUSTER_VG is never set during LCK_UNLOCK,
unlock_vg() takes only vgname as argument and cannot
distinguish if vg is clustered, leaving flag unset
(that flag is set only if locking LV).

The idea is call remote backup from archiver directly,
here from backup() call.

If called from clvmd, the new flag is set to perform
only local_backup.

Lock is now trigered by LCK_VG_BACKUP flag
combination (I hope unused one:-).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    6 +++++-
 lib/format_text/archiver.c    |   13 +++++++++++--
 lib/locking/cluster_locking.c |   15 +++++++--------
 lib/locking/locking.h         |    3 +++
 4 files changed, 26 insertions(+), 11 deletions(-)

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
index 0406ae5..a3efc3e 100644
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
+static int _backup(struct volume_group *vg, int local_only)
 {
 	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
 		log_warn("WARNING: This metadata update is NOT backed up");
@@ -222,6 +223,9 @@ int backup(struct volume_group *vg)
 	    (errno == EROFS))
 		return 0;
 
+	if (!local_only && vg_is_clustered(vg))
+		remote_backup_metadata(vg);
+
 	if (!__backup(vg)) {
 		log_error("Backup of volume group %s metadata failed.",
 			  vg->name);
@@ -231,6 +235,11 @@ int backup(struct volume_group *vg)
 	return 1;
 }
 
+int backup(struct volume_group *vg)
+{
+	return _backup(vg, 0);
+}
+
 int backup_remove(struct cmd_context *cmd, const char *vg_name)
 {
 	char path[PATH_MAX];
@@ -412,5 +421,5 @@ void check_current_backup(struct volume_group *vg)
 	if (vg_backup)
 		archive(vg_backup);
 	archive(vg);
-	backup(vg);
+	_backup(vg, 1);
 }
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
index a00d742..3844ed1 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -101,6 +101,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
 #define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
+#define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL | LCK_NONBLOCK)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE | LCK_NONBLOCK)
@@ -128,6 +129,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
+#define remote_backup_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);



