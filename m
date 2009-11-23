From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Nov 2009 10:55:14 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20091123105514.5325.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-23 10:55:14

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Fix memory lock imbalance in locking code.
	
	(This affects only cluster locking because only cluster
	locking module set LCK_PRE_MEMLOCK.)
	
	With currect code you get
	# vgchange -a n
	Internal error: _memlock_count has dropped below 0.
	when using cluster locking.
	
	It is caused by _unlock_memory calls here
	
	if ((flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME)
	memlock_dec();
	
	Unfortunately it is also (wrongly) called in immediate unlock
	(when LCK_HOLD is not set) from lock_vol
	(LCK_UNLOCK is misinterpreted as LCK_LV_RESUME).
	
	Avoid this by comparing original flags and provide memlock
	code type of operation (suspend/resume).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1321&r2=1.1322
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/WHATS_NEW	2009/11/23 10:44:50	1.1321
+++ LVM2/WHATS_NEW	2009/11/23 10:55:14	1.1322
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Fix memory lock imbalance in locking code.
   Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)
 
 Version 2.02.55 - 19th November 2009
--- LVM2/lib/locking/locking.c	2009/09/14 22:47:49	1.66
+++ LVM2/lib/locking/locking.c	2009/11/23 10:55:14	1.67
@@ -42,6 +42,12 @@
 static struct sigaction _oldhandler;
 static int _oldmasked;
 
+typedef enum {
+        LV_NOOP,
+        LV_SUSPEND,
+        LV_RESUME
+} lv_operation_t;
+
 static void _catch_sigint(int unused __attribute__((unused)))
 {
 	_sigint_caught = 1;
@@ -159,21 +165,21 @@
 	return;
 }
 
-static void _lock_memory(uint32_t flags)
+static void _lock_memory(lv_operation_t lv_op)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
 		return;
 
-	if ((flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND)
+	if (lv_op == LV_SUSPEND)
 		memlock_inc();
 }
 
-static void _unlock_memory(uint32_t flags)
+static void _unlock_memory(lv_operation_t lv_op)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
 		return;
 
-	if ((flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME)
+	if (lv_op == LV_RESUME)
 		memlock_dec();
 }
 
@@ -336,12 +342,13 @@
  * VG locking is by VG name.
  * FIXME This should become VG uuid.
  */
-static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t flags)
+static int _lock_vol(struct cmd_context *cmd, const char *resource,
+		     uint32_t flags, lv_operation_t lv_op)
 {
 	int ret = 0;
 
 	_block_signals(flags);
-	_lock_memory(flags);
+	_lock_memory(lv_op);
 
 	assert(resource);
 
@@ -368,7 +375,7 @@
 		_update_vg_lock_count(resource, flags);
 	}
 
-	_unlock_memory(flags);
+	_unlock_memory(lv_op);
 	_unblock_signals();
 
 	return ret;
@@ -377,6 +384,18 @@
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 {
 	char resource[258] __attribute((aligned(8)));
+	lv_operation_t lv_op;
+
+	switch (flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) {
+		case LCK_LV_SUSPEND:
+				lv_op = LV_SUSPEND;
+				break;
+		case LCK_LV_RESUME:
+				lv_op = LV_RESUME;
+				break;
+		default:	lv_op = LV_NOOP;
+	}
+
 
 	if (flags == LCK_NONE) {
 		log_debug("Internal error: %s: LCK_NONE lock requested", vol);
@@ -416,7 +435,7 @@
 
 	strncpy(resource, vol, sizeof(resource));
 
-	if (!_lock_vol(cmd, resource, flags))
+	if (!_lock_vol(cmd, resource, flags, lv_op))
 		return 0;
 
 	/*
@@ -426,7 +445,7 @@
 	if (!(flags & LCK_CACHE) && !(flags & LCK_HOLD) &&
 	    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK)) {
 		if (!_lock_vol(cmd, resource,
-			       (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
+			       (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, lv_op))
 			return 0;
 	}
 


