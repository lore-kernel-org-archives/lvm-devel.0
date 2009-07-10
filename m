From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 20:08:38 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgremove.c
Message-ID: <20090710200838.25508.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 20:08:38

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgremove.c 

Log message:
	Move orphan lock inside vg_remove_single.
	
	Move the vg orphan lock inside vg_remove_single, now a complete liblvm
	function.  Note that this changes the order of the locks - originally
	VG_ORPHAN was obtained first, then the vgname lock.  With the current
	policy of non-blocking second locks, this could mean we get a failure
	obtaining the orphan lock.  In the case of a vg with lvs being removed,
	this could result in the lvs being removed but not the vg.  Such a
	scenario could have happened prior though with a different failure.
	Other tools were examined for side-effects, and no major problems
	were noted.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.243&r2=1.244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/lib/metadata/metadata.c	2009/07/10 20:07:02	1.243
+++ LVM2/lib/metadata/metadata.c	2009/07/10 20:08:37	1.244
@@ -388,8 +388,14 @@
 	if (!archive(vg))
 		return 0;
 
+	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
 	if (!vg_remove(vg)) {
 		log_error("vg_remove %s failed", vg->name);
+		unlock_vg(vg->cmd, VG_ORPHANS);
 		return 0;
 	}
 
@@ -423,6 +429,7 @@
 	else
 		log_error("Volume group \"%s\" not properly removed", vg->name);
 
+	unlock_vg(vg->cmd, VG_ORPHANS);
 	return ret;
 }
 
--- LVM2/tools/vgremove.c	2009/07/10 20:07:03	1.52
+++ LVM2/tools/vgremove.c	2009/07/10 20:08:38	1.53
@@ -56,16 +56,9 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	ret = process_each_vg(cmd, argc, argv,
 			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
-	unlock_vg(cmd, VG_ORPHANS);
-
 	return ret;
 }


