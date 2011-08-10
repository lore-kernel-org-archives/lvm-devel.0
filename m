From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Aug 2011 16:07:54 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20110810160754.10071.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-10 16:07:54

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	If anything bad happens and unlocking fails
	(here clvmd crashed in the middle of operation),
	lock is not removed from cache - here is one example:
	
	locking/cluster_locking.c:497       Locking VG V_vg_test UN (VG) (0x6)
	locking/cluster_locking.c:113   Error writing data to clvmd: Broken pipe
	locking/locking.c:399         <backtrace>
	locking/locking.c:461         <backtrace>
	Internal error: Volume Group vg_test was not unlocked
	
	Code should always remove lock info from lvmcache and update counters
	on unlock, even if unlock fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2055&r2=1.2056
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2011/08/10 11:00:32	1.2055
+++ LVM2/WHATS_NEW	2011/08/10 16:07:53	1.2056
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Remove lock from cache even if unlock fails.
   Initialise clvmd locks before lvm context to avoid open descriptor leaks.
   Remove obsoleted GULM clvmd cluster locking support.
   Suppress low-level locking errors and warnings while using --sysinit.
--- LVM2/lib/locking/locking.c	2011/08/09 11:44:57	1.96
+++ LVM2/lib/locking/locking.c	2011/08/10 16:07:54	1.97
@@ -359,6 +359,8 @@
 static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		     uint32_t flags, lv_operation_t lv_op)
 {
+	uint32_t lck_type = flags & LCK_TYPE_MASK;
+	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 	int ret = 0;
 
 	_block_signals(flags);
@@ -376,21 +378,16 @@
 		return 0;
 	}
 
-	if (cmd->metadata_read_only &&
-	    ((flags & LCK_TYPE_MASK) == LCK_WRITE) &&
+	if (cmd->metadata_read_only && lck_type == LCK_WRITE &&
 	    strcmp(resource, VG_GLOBAL)) {
 		log_error("Operation prohibited while global/metadata_read_only is set.");
 		return 0;
 	}
 
 	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
-		if ((flags & LCK_SCOPE_MASK) == LCK_VG &&
-		    !(flags & LCK_CACHE)) {
-			if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
-				lvmcache_unlock_vgname(resource);
-			else
-				lvmcache_lock_vgname(resource, (flags & LCK_TYPE_MASK)
-								== LCK_READ);
+		if (lck_scope == LCK_VG && !(flags & LCK_CACHE)) {
+			if (lck_type != LCK_UNLOCK)
+				lvmcache_lock_vgname(resource, lck_type == LCK_READ);
 			dev_reset_error_count(cmd);
 		}
 
@@ -398,6 +395,13 @@
 	} else
 		stack;
 
+	/* If unlocking, always remove lock from lvmcache even if operation failed. */
+	if (lck_scope == LCK_VG && !(flags & LCK_CACHE) && lck_type == LCK_UNLOCK) {
+		lvmcache_unlock_vgname(resource);
+		if (!ret)
+			_update_vg_lock_count(resource, flags);
+	}
+
 	_unlock_memory(cmd, lv_op);
 	_unblock_signals();
 


