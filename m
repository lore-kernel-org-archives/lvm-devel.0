From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Apr 2011 20:30:01 -0000
Subject: LVM2/lib locking/locking.c locking/locking.h m ...
Message-ID: <20110428203001.9308.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-28 20:30:00

Modified files:
	lib/locking    : locking.c locking.h 
	lib/metadata   : metadata-exported.h mirror.c 
	lib/mm         : memlock.h 

Log message:
	clean up critical section patch

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.189&r2=1.190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/locking/locking.c	2011/02/18 14:16:12	1.93
+++ LVM2/lib/locking/locking.c	2011/04/28 20:29:59	1.94
@@ -574,11 +574,13 @@
 int sync_local_dev_names(struct cmd_context* cmd)
 {
 	memlock_unlock(cmd);
-	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL);
+
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC_LOCAL);
 }
 
 int sync_dev_names(struct cmd_context* cmd)
 {
 	memlock_unlock(cmd);
-	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE);
+
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC);
 }
--- LVM2/lib/locking/locking.h	2011/02/18 14:16:12	1.63
+++ LVM2/lib/locking/locking.h	2011/04/28 20:29:59	1.64
@@ -39,6 +39,9 @@
  *   acquired in alphabetical order of 'vol' (to avoid deadlocks), with
  *   VG_ORPHANS last.
  *
+ *   Use VG_SYNC_NAMES to wait for any outstanding asynchronous /dev nodes 
+ *   events to complete.
+ *
  * LCK_LV:
  *   Lock/unlock an individual logical volume
  *   char *vol holds lvid
@@ -127,6 +130,9 @@
 
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
+#define LCK_VG_SYNC		(LCK_NONE | LCK_CACHE)
+#define LCK_VG_SYNC_LOCAL	(LCK_NONE | LCK_CACHE | LCK_LOCAL)
+
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE)
 #define LCK_LV_RESUME		(LCK_LV | LCK_UNLOCK)
@@ -175,12 +181,7 @@
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
-/* cleanup later
-#define sync_local_dev_names(cmd)	\
-	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL)
-#define sync_dev_names(cmd)	\
-	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE)
-*/
+
 int sync_local_dev_names(struct cmd_context* cmd);
 int sync_dev_names(struct cmd_context* cmd);
 
--- LVM2/lib/metadata/metadata-exported.h	2011/04/06 21:32:20	1.189
+++ LVM2/lib/metadata/metadata-exported.h	2011/04/28 20:30:00	1.190
@@ -196,7 +196,7 @@
 #define FMT_INSTANCE_PRIVATE_MDAS 	0x00000008U
 
 struct format_instance {
-	unsigned ref_count;
+	unsigned ref_count;	/* Refs to this fid from VG and PV structs */
 	struct dm_pool *mem;
 
 	uint32_t type;
--- LVM2/lib/metadata/mirror.c	2011/04/12 14:13:17	1.150
+++ LVM2/lib/metadata/mirror.c	2011/04/28 20:30:00	1.151
@@ -987,11 +987,11 @@
 	}
 
 	/* FIXME: second suspend should not be needed
-	 * Explicitly suspend temporary LV
-	 * This balance critical_section_inc() calls with critical_section_dec() in resume
-	 * (both localy and in cluster) and also properly propagates precommited
+	 * Explicitly suspend temporary LV.
+	 * This balances critical_section_inc() calls with critical_section_dec()
+	 * in resume (both local and cluster) and also properly propagates precommitted
 	 * metadata into dm table on other nodes.
-	 * (visible flag set causes the suspend is not properly propagated?)
+	 * FIXME: check propagation of suspend with visible flag
 	 */
 	if (temp_layer_lv && !suspend_lv(temp_layer_lv->vg->cmd, temp_layer_lv))
 		log_error("Problem suspending temporary LV %s", temp_layer_lv->name);
--- LVM2/lib/mm/memlock.h	2011/02/18 14:16:12	1.7
+++ LVM2/lib/mm/memlock.h	2011/04/28 20:30:00	1.8
@@ -18,6 +18,19 @@
 
 struct cmd_context;
 
+/*
+ * Inside a critical section, memory is always locked.
+ *
+ * After leaving the critical section, memory stays locked until 
+ * memlock_unlock() is called.  This happens with
+ * sync_local_dev_names() and sync_dev_names().
+ *
+ * This allows critical sections to be entered and exited repeatedly without
+ * incurring the expense of locking memory every time.
+ *
+ * memlock_reset() is necessary to clear the state after forking (polldaemon).
+ */
+
 void critical_section_inc(struct cmd_context *cmd);
 void critical_section_dec(struct cmd_context *cmd);
 int critical_section(void);

