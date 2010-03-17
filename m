From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Mar 2010 14:44:20 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c test/ ...
Message-ID: <20100317144420.23080.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-17 14:44:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	test           : t-vgsplit-stacked.sh 

Log message:
	Fix pvcreate device check.
	
	If user try to vgcreate or vgextend non-existent VG,
	these messages appears:
	
	# vgcreate xxx /dev/xxx
	Internal error: Volume Group xxx was not unlocked
	Device /dev/xxx not found (or ignored by filtering).
	Unable to add physical volume '/dev/xxx' to volume group 'xxx'.
	Internal error: Attempt to unlock unlocked VG xxx.
	
	(the same with existing VG and non-existing PV & vgextend)
	# vgextend vg_test /dev/xxx
	...
	
	It is caused because code tries to "refresh" cache if
	md filter is switched on using cache destroy.
	
	But we can change filters and rescan even without this
	machinery now, just use refresh_filters
	(and reset md filter afterwards).
	
	(Patch also  discovers cache alias bug in vgsplit test,
	fix it by using better filter line.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1465&r2=1.1466
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.322&r2=1.323
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/03/17 02:11:18	1.1465
+++ LVM2/WHATS_NEW	2010/03/17 14:44:18	1.1466
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Fix pvcreate device md filter check.
   Suppress repeated errors about the same missing PV uuids.
   Bypass full device scans when using internally-cached VG metadata.
   Only do one full device scan during each read of text format metadata.
--- LVM2/lib/metadata/metadata.c	2010/03/16 17:30:02	1.322
+++ LVM2/lib/metadata/metadata.c	2010/03/17 14:44:18	1.323
@@ -1290,18 +1290,10 @@
 	dev = dev_cache_get(name, cmd->filter);
 
 	/* Is there an md superblock here? */
+	/* FIXME: still possible issues here - rescan cache? */
 	if (!dev && md_filtering()) {
-		unlock_vg(cmd, VG_ORPHANS);
-
-		persistent_filter_wipe(cmd->filter);
-		lvmcache_destroy(cmd, 1);
-
+		refresh_filters(cmd);
 		init_md_filtering(0);
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphan PVs");
-			init_md_filtering(1);
-			return 0;
-		}
 		dev = dev_cache_get(name, cmd->filter);
 		init_md_filtering(1);
 	}
--- LVM2/test/t-vgsplit-stacked.sh	2009/08/02 21:45:45	1.1
+++ LVM2/test/t-vgsplit-stacked.sh	2010/03/17 14:44:19	1.2
@@ -1,6 +1,6 @@
 . ./test-utils.sh
 
-prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 aux prepare_devs 3
 
 pvcreate $devs


