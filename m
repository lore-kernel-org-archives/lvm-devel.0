From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Sep 2009 13:49:12 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/cache/lv ...
Message-ID: <20090915134912.15806.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-15 13:49:11

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/cache      : lvmcache.c 
	man            : lvm.conf.5.in 
	tools          : toollib.c 

Log message:
	pre-release cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1263&r2=1.1264
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170

--- LVM2/WHATS_NEW	2009/09/15 11:41:38	1.1263
+++ LVM2/WHATS_NEW	2009/09/15 13:49:10	1.1264
@@ -4,31 +4,32 @@
   Add lots of missing stack debug messages to tools.
   Make readonly locking available as locking type 4.
   Fix readonly locking to permit writeable global locks (for vgscan). (2.02.49)
-  Add lvm_vg_is_clustered, lvm_vg_is_exported, and lvm_vg_is_partial.
-  Add DM_UDEV_RULES_VSN udev enviroment variable.
-  Add libudev configuration check.
-  Add lvm2app.sh to nightly tests conditional upon configure --enable-applib.
-  Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
-  Enforce an alphabetical lock ordering for vgname locks.
-  Refactor vgsplit, vgmerge, and vgrename to obey vgname ordering rules.
-  Implement write lock prioritisation for file locking and make it default.
-  Fix clvmd autodetection check and cleanup related configure messages.
-  Fix Makefile distclean target.
-  Make clvmd check corosync to see what cluster interface it should use.
-  Rewrite clvmd configuration code to cope with all combinations of libs.
+  Add DM_UDEV_RULES_VSN environment variable to udev rules.
+  Update vgsplit, vgmerge, and vgrename to obey new vgname ordering rules.
+  Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
+  Enforce an alphabetical lock ordering on vgname locking.
+  Prioritise write locks over read locks by default for file locking.
+  Add local lock files with suffix ':aux' to serialise locking requests.
   Fix global locking in PV reporting commands (2.02.49).
   Fix pvcreate string termination in duplicate uuid warning message.
-  Fix pvcreate on a partition (2.02.51).
+  Don't loop reading sysfs with pvcreate on a non-blkext partition (2.02.51).
   Fix vgcfgrestore error paths when locking fails (2.02.49).
+  Update Makefile distclean target.
+  Add libudev configuration check.
+  Make clvmd check corosync to see what cluster interface it should use.
+  Add clvmd autodetection check and cleanup related configure messages.
+  Rewrite clvmd configuration code to cope with all combinations of libs.
   Added configure --enable-cmirrord to build the cluster mirror log daemon.
   Rename clogd to cmirrord.
   Make lvchange --refresh only take a read lock on volume group.
-  Fix bug where non-blocking file locks could be granted in error.
-  Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
+  Fix race where non-blocking file locks could be granted in error.
   Fix vgextend error path - if ORPHAN lock fails, unlock / release vg (2.02.49).
   Fix compile warning in clvmd.
-  Update lv{convert|create|extend|resize} man pages - clarify use of PE ranges.
+  Clarify use of PE ranges in lv{convert|create|extend|resize} man pages.
   Remove useless _pv_write wrapper.
+  Add lvm2app.sh to tests conditional upon configure --enable-applib.
+  Add lvm_vg_is_clustered, lvm_vg_is_exported, and lvm_vg_is_partial.
+  Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
   Update test/api/test.c to call lvm_vg_create and lvm_vg_remove.
 
 Version 2.02.51 - 6th August 2009
--- LVM2/doc/example.conf	2009/09/11 15:53:58	1.47
+++ LVM2/doc/example.conf	2009/09/15 13:49:11	1.48
@@ -266,6 +266,8 @@
     # if LVM2 commands get run concurrently).
     # Type 2 uses the external shared library locking_library.
     # Type 3 uses built-in clustered locking.
+    # Type 4 uses read-only locking which forbids any operations that might 
+    # change metadata.
     locking_type = 1
 
     # Set to 0 to fail when a lock request cannot be satisfied immediately.
@@ -288,11 +290,13 @@
     # in progress.  A directory like /tmp that may get wiped on reboot is OK.
     locking_dir = "/var/lock/lvm"
 
-    # Whenever a read-only and read-write access compete on a single volume
-    # group, ensure that the write lock gets priority over the read lock.
-    # Without this setting, write access may be stalled by high volume of
-    # read-only traffic on LVM metadata. NB. This option only affects
-    # locking_type = 1, i.e. local file-based locking.
+    # Whenever there are competing read-only and read-write access requests for
+    # a volume group's metadata, instead of always granting the read-only
+    # requests immediately, delay them to allow the read-write requests to be
+    # serviced.  Without this setting, write access may be stalled by a high
+    # volume of read-only requests.
+    # NB. This option only affects locking_type = 1 viz. local file-based
+    # locking.
     prioritise_write_locks = 1
 
     # Other entries can go here to allow you to load shared libraries
--- LVM2/lib/cache/lvmcache.c	2009/09/14 19:44:15	1.68
+++ LVM2/lib/cache/lvmcache.c	2009/09/15 13:49:11	1.69
@@ -192,11 +192,12 @@
  */
 static int _vgname_order_correct(const char *vgname1, const char *vgname2)
 {
-	if ((*vgname1 == '#')|(*vgname2 == '#'))
+	if ((*vgname1 == '#') || (*vgname2 == '#'))
 		return 1;
 
 	if (strcmp(vgname1, vgname2) < 0)
 		return 1;
+
 	return 0;
 }
 
@@ -214,7 +215,9 @@
 	dm_hash_iterate(n, _lock_hash) {
 		if (!dm_hash_get_data(_lock_hash, n))
 			return_0;
+
 		vgname2 = dm_hash_get_key(_lock_hash, n);
+
 		if (!_vgname_order_correct(vgname2, vgname)) {
 			log_errno(EDEADLK, "Internal error: VG lock %s must "
 				  "be requested before %s, not after.",
@@ -222,6 +225,7 @@
 			return_0;
 		}
 	}
+
 	return 1;
 }
 
--- LVM2/man/lvm.conf.5.in	2009/08/01 17:08:44	1.6
+++ LVM2/man/lvm.conf.5.in	2009/09/15 13:49:11	1.7
@@ -286,6 +286,8 @@
 (see below).
 If the tools were configured \fB--with-cluster=internal\fP 
 (the default) then 3 means to use built-in cluster-wide locking.
+Type 4 enforces read-only metadata and forbids any operations that
+might want to modify Volume Group metadata.
 All changes to logical volumes and their states are communicated
 using locks.
 .IP
--- LVM2/tools/toollib.c	2009/09/15 01:38:59	1.169
+++ LVM2/tools/toollib.c	2009/09/15 13:49:11	1.170
@@ -434,10 +434,10 @@
 	vg = vg_read(cmd, vg_name, vgid, flags);
 	/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
 	if (vg_read_error(vg) &&
-	    !((vg_read_error(vg) == FAILED_INCONSISTENT)&&(flags & READ_ALLOW_INCONSISTENT))) {
+	    !((vg_read_error(vg) == FAILED_INCONSISTENT) &&
+	      (flags & READ_ALLOW_INCONSISTENT))) {
 		ret_max = ECMD_FAILED;
-		stack;
-		goto out;
+		goto_out;
 	}
 
 	if (!dm_list_empty(tags)) {


