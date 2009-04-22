From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Apr 2009 09:39:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20090422093947.26715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-22 09:39:46

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	lib/format_text: archiver.c archiver.h 
	lib/locking    : cluster_locking.c locking.h 

Log message:
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

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1092&r2=1.1093
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2009/04/22 09:31:30	1.1092
+++ LVM2/WHATS_NEW	2009/04/22 09:39:45	1.1093
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix remote metadata backup for clvmd.
   Alloc PV internal structure from VG mempool if possible.
   Fix metadata backup to run after vg_commit always.
   Tidy clvmd volume lock cache functions.
--- LVM2/daemons/clvmd/clvmd-command.c	2008/11/04 16:41:47	1.26
+++ LVM2/daemons/clvmd/clvmd-command.c	2009/04/22 09:39:45	1.27
@@ -159,7 +159,11 @@
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
--- LVM2/lib/format_text/archiver.c	2009/04/10 10:00:37	1.23
+++ LVM2/lib/format_text/archiver.c	2009/04/22 09:39:46	1.24
@@ -20,6 +20,7 @@
 #include "lvm-string.h"
 #include "lvmcache.h"
 #include "toolcontext.h"
+#include "locking.h"
 
 #include <unistd.h>
 
@@ -202,7 +203,7 @@
 	return backup_to_file(name, desc, vg);
 }
 
-int backup(struct volume_group *vg)
+int backup_locally(struct volume_group *vg)
 {
 	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
 		log_warn("WARNING: This metadata update is NOT backed up");
@@ -231,6 +232,14 @@
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
@@ -426,5 +435,5 @@
 		vg_release(vg_backup);
 	}
 	archive(vg);
-	backup(vg);
+	backup_locally(vg);
 }
--- LVM2/lib/format_text/archiver.h	2008/12/11 03:33:35	1.6
+++ LVM2/lib/format_text/archiver.h	2009/04/22 09:39:46	1.7
@@ -46,6 +46,7 @@
 
 void backup_enable(struct cmd_context *cmd, int flag);
 int backup(struct volume_group *vg);
+int backup_locally(struct volume_group *vg);
 int backup_remove(struct cmd_context *cmd, const char *vg_name);
 
 struct volume_group *backup_read_vg(struct cmd_context *cmd,
--- LVM2/lib/locking/cluster_locking.c	2008/12/16 12:30:39	1.32
+++ LVM2/lib/locking/cluster_locking.c	2009/04/22 09:39:46	1.33
@@ -385,6 +385,13 @@
 
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
@@ -436,14 +443,6 @@
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
--- LVM2/lib/locking/locking.h	2009/04/10 09:59:19	1.44
+++ LVM2/lib/locking/locking.h	2009/04/22 09:39:46	1.45
@@ -101,6 +101,7 @@
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
 #define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
+#define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL | LCK_NONBLOCK)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE | LCK_NONBLOCK)
@@ -131,6 +132,8 @@
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
+#define remote_backup_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);


