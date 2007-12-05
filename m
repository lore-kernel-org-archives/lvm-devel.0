From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 5 Dec 2007 13:17:19 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c daemons/clv ...
Message-ID: <20071205131719.16438.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-12-05 13:17:18

Modified files:
	daemons/clvmd  : lvm-functions.c lvm-functions.h 
	lib/locking    : cluster_locking.c 

Log message:
	Tidy the clvmd backup code.
	Move the backups inside the protection of the VG lock,
	Don't backup if we have a suspended LV
	Correct the vg_read() call

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/daemons/clvmd/lvm-functions.c	2007/12/04 15:39:26	1.36
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/12/05 13:17:18	1.37
@@ -54,6 +54,7 @@
 static pthread_mutex_t lv_hash_lock;
 static pthread_mutex_t lvm_lock;
 static char last_error[1024];
+static int suspended = 0;
 
 struct lv_info {
 	int lock_id;
@@ -340,11 +341,15 @@
 
 	case LCK_LV_SUSPEND:
 		status = do_suspend_lv(resource);
+		if (!status)
+			suspended++;
 		break;
 
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
 		status = do_resume_lv(resource);
+		if (!status)
+			suspended--;
 		break;
 
 	case LCK_LV_ACTIVATE:
@@ -602,18 +607,21 @@
 }
 
 /* Backups up the LVM metadata if it's changed */
-void lvm_do_backup(char *vgname)
+void lvm_do_backup(const char *vgname)
 {
 	struct volume_group * vg;
-	int consistent;
+	int consistent = 0;
 
-	DEBUGLOG("Triggering backup of VG metadata for %s\n", vgname);
+	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
 
 	vg = vg_read(cmd, vgname, NULL /*vgid*/, &consistent);
-	if (vg)
-		check_current_backup(vg);
-	else
+	if (vg) {
+		if (consistent)
+			check_current_backup(vg);
+	}
+	else {
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
+	}
 }
 
 /* Called to initialise the LVM context of the daemon */
--- LVM2/daemons/clvmd/lvm-functions.h	2007/12/04 15:39:26	1.6
+++ LVM2/daemons/clvmd/lvm-functions.h	2007/12/05 13:17:18	1.7
@@ -28,7 +28,7 @@
 extern int do_refresh_cache(void);
 extern int init_lvm(int using_gulm);
 extern void init_lvhash(void);
-extern void lvm_do_backup(char *vgname);
+extern void lvm_do_backup(const char *vgname);
 extern int hold_unlock(char *resource);
 extern int hold_lock(char *resource, int mode, int flags);
 extern void unlock_all(void);
--- LVM2/lib/locking/cluster_locking.c	2007/12/04 15:39:26	1.23
+++ LVM2/lib/locking/cluster_locking.c	2007/12/05 13:17:18	1.24
@@ -378,7 +378,6 @@
 {
 	char lockname[PATH_MAX];
 	int cluster_cmd = 0;
-	int ret;
 	const char *lock_scope;
 	const char *lock_type = "";
 
@@ -439,6 +438,12 @@
 		return 0;
 	}
 
+	/* If we are unlocking a VG, then trigger remote metadata backups */
+	if (cluster_cmd == CLVMD_CMD_LOCK_VG && ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)) {
+		log_very_verbose("Requesing backup of VG metadata for %s", resource);
+		_lock_for_cluster(CLVMD_CMD_VG_BACKUP, LCK_CLUSTER_VG, resource);
+	}
+
 	log_very_verbose("Locking %s %s %s %s%s%s%s (0x%x)", lock_scope, lockname,
 			 lock_type,
 			 flags & LCK_NONBLOCK ? "" : "B", 
@@ -448,13 +453,7 @@
 			 flags);
 
 	/* Send a message to the cluster manager */
-	ret = _lock_for_cluster(cluster_cmd, flags, lockname);
-
-	/* If we are unlocking a VG, then trigger remote metadata backups */
-	if (ret && cluster_cmd == CLVMD_CMD_LOCK_VG && ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)) {
-		ret = _lock_for_cluster(CLVMD_CMD_VG_BACKUP, LCK_CLUSTER_VG, resource);
-	}
-	return ret;
+	return _lock_for_cluster(cluster_cmd, flags, lockname);
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL


