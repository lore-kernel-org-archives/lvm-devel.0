From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Dec 2010 17:37:12 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM daemons/clvmd/ ...
Message-ID: <20101206173712.19399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-06 17:37:10

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix debug logging of derived flag LCK_CACHE in clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1826&r2=1.1827
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.427&r2=1.428
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2010/12/01 13:05:06	1.1826
+++ LVM2/WHATS_NEW	2010/12/06 17:37:09	1.1827
@@ -1,23 +1,23 @@
 Version 2.02.78 - 
 ====================================
-  Check str_list_add() success in _add_stripe_seg().
-  Check lv_info() success in _mirrored_transient_status().
+  Abort if segment tag allocation fails in pool format _add_stripe_seg.
+  Abort in _mirrored_transient_status if referenced log/image LV is not active.
   Add backtraces for dev_set() and dev_close_immediate() errors in set_lv().
-  Add logging for unlink() error in clvmd remove_lockfile().
-  Add logging for pipe write() and close() error in clvmd child_init_signal().
-  Add test for existance of orphan vginfo in _lvmcache_update_vgname().
-  Do a full rescan if some device is missing in read_pvs_in_vg().
-  Avoid misleading warnings in vgextend --restoremissing in certain cases.
-  Add error path stack traces for _process_mapper_dir(), _create_and_load_v4().
-  Add missing test for failed pool allocation in write_config_node().
-  Replace snprintf with dm_snprintf in clvmd-command.c.
-  Check reallocated buffer for NULL before use in clvmd do_command().
+  Log any unlink() error in clvmd remove_lockfile().
+  Log any pipe write() or close() errors in clvmd child_init_signal().
+  Detect if orphan vginfo was lost from cache before _lvmcache_update_vgname().
+  Do a full rescan if some device is missing in lvm1 format read_pvs_in_vg.
+  Add missing check that dm_pool_create succeeded in write_config_node().
+  Use dm_snprintf in clvmd-command.c to ensure an overlong buffer is truncated.
+  Don't write to buffer if its reallocation failed in clvmd do_command().
+  Switch from float to fixed point percentage handling.
+  Avoid misleading missing PV warnings in vgextend --restoremissing.
   Fix memory leak when VG allocation policy in metadata is invalid.
   Ignore unrecognised allocation policy found in metadata instead of aborting.
   Factor out tag printing into _out_tags and avoid leaking string buffer.
   Remove some unused variables & assignments.
   Add missing vg_release calls in _vg_read_by_vgid.
-Still to fix: LCK_CACHE/CLUSTER_VG printing/FIXME
+  Fix debug logging of derived flag LCK_CACHE in clvmd.
   Fix test for no system_dir in _init_backup().
   Disallow lvconvert ops that both allocate & free supplied PEs in a single cmd.
   Fix liblvm seg_size to give bytes not sectors.
--- LVM2/WHATS_NEW_DM	2010/11/29 18:35:37	1.427
+++ LVM2/WHATS_NEW_DM	2010/12/06 17:37:09	1.428
@@ -1,5 +1,6 @@
 Version 1.02.59 - 
 ====================================
+  Add backtraces to _process_mapper_dir and  _create_and_load_v4 error paths.
   Remove superfluous checks for NULL before calling dm_free.
 
 Version 1.02.58 - 22nd November 2010
--- LVM2/daemons/clvmd/lvm-functions.c	2010/11/29 11:05:15	1.101
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/12/06 17:37:09	1.102
@@ -44,11 +44,7 @@
 	int lock_mode;
 };
 
-/*
- * FIXME: 8bit value passed here -
- *        so only LCK_XXX defines < 0x100 can be decoded
- */
-static const char *decode_locking_cmd(unsigned char cmdl)
+static const char *decode_full_locking_cmd(uint32_t cmdl)
 {
 	static char buf[128];
 	const char *type;
@@ -117,11 +113,20 @@
 		cmdl & LCK_NONBLOCK   ? "|NONBLOCK" : "",
 		cmdl & LCK_HOLD       ? "|HOLD" : "",
 		cmdl & LCK_LOCAL      ? "|LOCAL" : "",
-		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "");
+		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "",
+		cmdl & LCK_CACHE      ? "|CACHE" : "");
 
 	return buf;
 }
 
+/*
+ * Only processes 8 bits: excludes LCK_CACHE.
+ */
+static const char *decode_locking_cmd(unsigned char cmdl)
+{
+	return decode_full_locking_cmd((uint32_t) cmdl);
+}
+
 static const char *decode_flags(unsigned char flags)
 {
 	static char buf[128];
@@ -676,15 +681,6 @@
 	uint32_t lock_cmd = command;
 	char *vgname = resource + 2;
 
-	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
-		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
-
-	/* P_#global causes a full cache refresh */
-	if (!strcmp(resource, "P_" VG_GLOBAL)) {
-		do_refresh_cache();
-		return;
-	}
-
 	lock_cmd &= (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_HOLD);
 
 	/*
@@ -693,6 +689,15 @@
 	if (strncmp(resource, "P_#", 3) && !strncmp(resource, "P_", 2))
 		lock_cmd |= LCK_CACHE;
 
+	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
+		 resource, decode_full_locking_cmd(lock_cmd), decode_flags(lock_flags), memlock());
+
+	/* P_#global causes a full cache refresh */
+	if (!strcmp(resource, "P_" VG_GLOBAL)) {
+		do_refresh_cache();
+		return;
+	}
+
 	pthread_mutex_lock(&lvm_lock);
 	switch (lock_cmd) {
 		case LCK_VG_COMMIT:


