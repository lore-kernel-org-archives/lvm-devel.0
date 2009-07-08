From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 14:33:18 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090708143318.21839.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 14:33:17

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgextend.c vgmerge.c vgreduce.c vgremove.c 
	                 vgsplit.c 

Log message:
	Remove unneeded LOCK_NONBLOCKING from vg_read() API.
	
	Remove unneeded LOCK_NONBLOCKING from vg_read() API and tools that
	use it.  We no longer need this flag anywhere since we now automatically
	set LCK_NONBLOCK inside lock_vol() if vgs_locked().
	For further details, see:
	commit d52b3fd3fe2006e2d13e42f8518b6512bff03710
	Author: Dave Wysochanski <dwysocha@redhat.com>
	Date:   Wed May 13 13:02:52 2009 +0000
	
	Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
	
	As a simplification to the tools and further liblvm, this patch pushes
	the setting of NON_BLOCKING lock flag inside the lock_vol() call.
	The policy we set is if any existing VGs are currently locked, we
	set the NON_BLOCKING flag.
	
	At some point it may make sense to add this flag back if we get an
	RFE from a liblvm user, but for now let's keep it as simple as
	possible.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.233&r2=1.234
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/lib/metadata/metadata-exported.h	2009/07/08 14:31:17	1.80
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/08 14:33:17	1.81
@@ -110,9 +110,6 @@
 #define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_REQUIRE_RESIZEABLE	0x00040000U
 
-/* FIXME Deduce these next requirements internally instead of having caller specify. */
-#define LOCK_NONBLOCKING	0x00000100U	/* Fail if not available immediately. */
-
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
 
--- LVM2/lib/metadata/metadata.c	2009/07/08 14:31:17	1.233
+++ LVM2/lib/metadata/metadata.c	2009/07/08 14:33:17	1.234
@@ -2845,9 +2845,6 @@
 	if (flags & READ_REQUIRE_RESIZEABLE)
 		status |= RESIZEABLE_VG;
 
-	if (flags & LOCK_NONBLOCKING)
-		lock_flags |= LCK_NONBLOCK;
-
 	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
 }
 
--- LVM2/tools/vgextend.c	2009/07/07 01:18:35	1.44
+++ LVM2/tools/vgextend.c	2009/07/08 14:33:17	1.45
@@ -43,7 +43,7 @@
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL,
-				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
+				READ_REQUIRE_RESIZEABLE);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
 		unlock_vg(cmd, VG_ORPHANS);
--- LVM2/tools/vgmerge.c	2009/07/07 01:18:35	1.59
+++ LVM2/tools/vgmerge.c	2009/07/08 14:33:17	1.60
@@ -35,8 +35,7 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
-				     LOCK_NONBLOCKING);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
 		vg_release(vg_from);
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
--- LVM2/tools/vgreduce.c	2009/07/01 17:01:46	1.93
+++ LVM2/tools/vgreduce.c	2009/07/08 14:33:17	1.94
@@ -424,7 +424,7 @@
 	vg->extent_count -= pv_pe_count(pv);
 
 	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
-				       NULL, LOCK_NONBLOCKING);
+				       NULL, 0);
 
 	if (vg_read_error(orphan_vg))
 		goto bad;
--- LVM2/tools/vgremove.c	2009/07/01 17:00:52	1.49
+++ LVM2/tools/vgremove.c	2009/07/08 14:33:17	1.50
@@ -41,7 +41,7 @@
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      READ_FOR_UPDATE | LOCK_NONBLOCKING,
+			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
--- LVM2/tools/vgsplit.c	2009/07/08 14:27:37	1.79
+++ LVM2/tools/vgsplit.c	2009/07/08 14:33:17	1.80
@@ -341,8 +341,7 @@
 	if (rc == FAILED_EXIST) {
 		existing_vg = 1;
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
-					   READ_REQUIRE_RESIZEABLE |
-					   LOCK_NONBLOCKING);
+					   READ_REQUIRE_RESIZEABLE);
 
 		if (vg_read_error(vg_to)) {
 			vg_release(vg_to);


