From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2011 19:18:18 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110204191818.21804.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-04 19:18:17

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	lib/locking    : external_locking.c file_locking.c locking.h 

Log message:
	Use cluster-wide message to request device name sync
	
	Thanks to CLVMD_CMD_SYNC_NAMES propagation fix the message passing started
	to work. So starts to send a message before the VG is unlocked.
	Removing also implicit sync in VG unlock from clmvd as now the message
	is delievered and processed in do_command().
	Also add support for this new message into external locking
	and mask this event from further processing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1903&r2=1.1904
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2011/02/04 19:14:39	1.1903
+++ LVM2/WHATS_NEW	2011/02/04 19:18:16	1.1904
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Use cluster-wide message to request device name sync.
   Fix operation node stacking for consecutive dm ops.
   Increase hash table size to 1024 lv names and 64 pv uuids.
   Remove fs_unlock() from lv_resume path.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/02/02 13:34:00	1.51
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/02/04 19:18:17	1.52
@@ -217,7 +217,6 @@
 	if (lkid == 0)
 	    return EINVAL;
 
-	lvm_do_fs_unlock(); /* Wait for devices */
 	status = sync_unlock(lockname, lkid);
 	if (status)
 	    status = errno;
--- LVM2/lib/locking/external_locking.c	2009/05/21 03:04:53	1.17
+++ LVM2/lib/locking/external_locking.c	2011/02/04 19:18:17	1.18
@@ -18,6 +18,8 @@
 #include "defaults.h"
 #include "sharedlib.h"
 #include "toolcontext.h"
+#include "activate.h"
+#include "locking.h"
 
 static void *_locking_lib = NULL;
 static void (*_reset_fn) (void) = NULL;
@@ -31,10 +33,16 @@
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
 			  uint32_t flags)
 {
-	if (_lock_fn)
-		return _lock_fn(cmd, resource, flags);
-	else
+	if (!_lock_fn)
 		return 0;
+
+	if (!strcmp(resource, VG_SYNC_NAMES)) {
+		/* Hide this lock request from external locking */
+		fs_unlock();
+		return 1;
+	}
+
+	return _lock_fn(cmd, resource, flags);
 }
 
 static void _fin_external_locking(void)
--- LVM2/lib/locking/file_locking.c	2011/02/02 13:34:00	1.56
+++ LVM2/lib/locking/file_locking.c	2011/02/04 19:18:17	1.57
@@ -215,7 +215,6 @@
 		state = 'W';
 		break;
 	case LCK_UNLOCK:
-		fs_unlock(); /* Wait until devices are available */
 		return _release_lock(file, 1);
 	default:
 		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
--- LVM2/lib/locking/locking.h	2011/01/12 20:42:51	1.60
+++ LVM2/lib/locking/locking.h	2011/02/04 19:18:17	1.61
@@ -143,7 +143,12 @@
 		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
 		0)
 
-#define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
+#define unlock_vg(cmd, vol)	\
+	do { \
+		if (is_real_vg(vol)) \
+			sync_dev_names(cmd); \
+		lock_vol(cmd, vol, LCK_VG_UNLOCK); \
+	} while (0)
 #define unlock_and_free_vg(cmd, vg, vol) \
 	do { \
 		unlock_vg(cmd, vol); \
@@ -172,6 +177,8 @@
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
 #define sync_local_dev_names(cmd)	\
 	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL)
+#define sync_dev_names(cmd)	\
+	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);


