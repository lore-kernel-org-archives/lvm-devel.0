From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2009 01:18:37 -0000
Subject: LVM2/tools lvcreate.c lvrename.c lvresize.c po ...
Message-ID: <20090707011837.27473.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-07 01:18:36

Modified files:
	tools          : lvcreate.c lvrename.c lvresize.c polldaemon.c 
	                 pvchange.c pvmove.c pvresize.c toollib.c 
	                 vgextend.c vgmerge.c vgrename.c vgsplit.c 

Log message:
	Fix vg_read() error paths to properly release upon vg_read_error().
	
	Fix vg_read() error paths to properly release upon vg_read_error().
	Note that in the iterator paths (process_each_*()), we release
	inside the iterator so no individual cleanup is needed.  However there
	are a number of other places we missed the cleanup.  Proper cleanup
	when vg_read_error() is true should be calling vg_release(vg), since
	there should be no locks held if we get an error (except in certain
	special cases, which IMO we should work to remove from the code).
	
	Unfortunately the testsuite is unable to detect these types of memory
	leaks.  Most of them can be easily seen if you try an operation
	(e.g. lvcreate) with a volume group that does not exist.  Error
	message looks like this:
	Volume group "vg2" not found
	You have a memory leak (not released memory pool):
	[0x1975eb8]
	You have a memory leak (not released memory pool):
	[0x1975eb8]
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/tools/lvcreate.c	2009/07/01 16:59:37	1.197
+++ LVM2/tools/lvcreate.c	2009/07/07 01:18:35	1.198
@@ -995,8 +995,10 @@
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return ECMD_FAILED;
+	}
 
 	if (!_lvcreate(cmd, vg, &lp))
 		r = ECMD_FAILED;
--- LVM2/tools/lvrename.c	2009/07/01 16:59:37	1.54
+++ LVM2/tools/lvrename.c	2009/07/07 01:18:35	1.55
@@ -103,8 +103,10 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return ECMD_FAILED;
+	}
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
 		log_error("Existing logical volume \"%s\" not found in "
--- LVM2/tools/lvresize.c	2009/07/01 16:59:37	1.113
+++ LVM2/tools/lvresize.c	2009/07/07 01:18:35	1.114
@@ -673,6 +673,7 @@
 	log_verbose("Finding volume group %s", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
+		vg_release(vg);
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/polldaemon.c	2009/07/01 17:05:12	1.20
+++ LVM2/tools/polldaemon.c	2009/07/07 01:18:35	1.21
@@ -150,6 +150,7 @@
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
+			vg_release(vg);
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
--- LVM2/tools/pvchange.c	2009/07/01 16:59:37	1.70
+++ LVM2/tools/pvchange.c	2009/07/07 01:18:35	1.71
@@ -58,8 +58,10 @@
 		log_verbose("Finding volume group %s of physical volume %s",
 			    vg_name, pv_name);
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-		if (vg_read_error(vg))
+		if (vg_read_error(vg)) {
+			vg_release(vg);
 			return_0;
+		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			log_error
--- LVM2/tools/pvmove.c	2009/07/01 16:59:37	1.64
+++ LVM2/tools/pvmove.c	2009/07/07 01:18:35	1.65
@@ -387,6 +387,7 @@
 
 	vg = _get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
+		vg_release(vg);
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/pvresize.c	2009/07/01 16:59:37	1.30
+++ LVM2/tools/pvresize.c	2009/07/07 01:18:35	1.31
@@ -100,7 +100,7 @@
 		log_error("%s: Couldn't get size.", pv_name);
 		goto bad;
 	}
-	
+
 	if (new_size) {
 		if (new_size > size)
 			log_warn("WARNING: %s: Overriding real size. "
@@ -127,7 +127,7 @@
 	if (vg) {
 		pv->size -= pv_pe_start(pv);
 		new_pe_count = pv_size(pv) / vg->extent_size;
-		
+
  		if (!new_pe_count) {
 			log_error("%s: Size must leave space for at "
 				  "least one physical extent of "
--- LVM2/tools/toollib.c	2009/07/01 17:00:52	1.159
+++ LVM2/tools/toollib.c	2009/07/07 01:18:35	1.160
@@ -354,6 +354,7 @@
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
 		if (vg_read_error(vg)) {
+			vg_release(vg);
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/vgextend.c	2009/07/01 16:59:37	1.43
+++ LVM2/tools/vgextend.c	2009/07/07 01:18:35	1.44
@@ -45,6 +45,7 @@
 	vg = vg_read_for_update(cmd, vg_name, NULL,
 				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
 	if (vg_read_error(vg)) {
+		vg_release(vg);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/vgmerge.c	2009/07/01 16:59:37	1.58
+++ LVM2/tools/vgmerge.c	2009/07/07 01:18:35	1.59
@@ -29,13 +29,16 @@
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
-	if (vg_read_error(vg_to))
-		 return ECMD_FAILED;
+	if (vg_read_error(vg_to)) {
+		vg_release(vg_to);
+		return ECMD_FAILED;
+	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
 				     LOCK_NONBLOCKING);
 	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/vgrename.c	2009/07/01 17:02:18	1.64
+++ LVM2/tools/vgrename.c	2009/07/07 01:18:35	1.65
@@ -73,8 +73,10 @@
 	/* FIXME we used to print an error about EXPORTED, but proceeded
 	   nevertheless. */
 	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		vg_release(vg);
 		return_0;
+	}
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
--- LVM2/tools/vgsplit.c	2009/07/01 17:04:21	1.77
+++ LVM2/tools/vgsplit.c	2009/07/07 01:18:35	1.78
@@ -317,8 +317,10 @@
 
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
 				     READ_REQUIRE_RESIZEABLE);
-	if (vg_read_error(vg_from))
+	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
 		return ECMD_FAILED;
+	}
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*


