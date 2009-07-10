From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 20:09:24 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgcreate.c ...
Message-ID: <20090710200924.25749.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 20:09:21

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgcreate.c vgextend.c 

Log message:
	Move orphan lock obtain/release inside vg_extend().
	
	With this change we now have vgcreate/vgextend liblvm functions.
	Note that this changes the lock order of the following functions as the
	orphan lock is now obtained first.  With our policy of non-blocking
	second locks, this should not be a problem.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.244&r2=1.245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/lib/metadata/metadata.c	2009/07/10 20:08:37	1.244
+++ LVM2/lib/metadata/metadata.c	2009/07/10 20:09:21	1.245
@@ -437,6 +437,12 @@
 {
 	int i;
 	struct physical_volume *pv;
+	struct cmd_context *cmd = vg->cmd;
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
@@ -445,18 +451,19 @@
 				  "physical volume", pv_names[i]);
 			goto bad;
 		}
-		
 		if (!add_pv_to_vg(vg, pv_names[i], pv))
 			goto bad;
 	}
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
+	unlock_vg(cmd, VG_ORPHANS);
 	return 1;
-	
+
       bad:
 	log_error("Unable to add physical volume '%s' to "
 		  "volume group '%s'.", pv_names[i], vg->name);
+	unlock_vg(cmd, VG_ORPHANS);
 	return 0;
 }
 
--- LVM2/tools/vgcreate.c	2009/07/09 10:09:33	1.63
+++ LVM2/tools/vgcreate.c	2009/07/10 20:09:21	1.64
@@ -46,12 +46,6 @@
 	if (validate_vg_create_params(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
-	/* FIXME: orphan lock needs tied to vg handle or inside library call */
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	/* Create the new VG */
 	vg = vg_create(cmd, vp_new.vg_name);
 	if (vg_read_error(vg))
@@ -113,7 +107,6 @@
 	}
 
 	unlock_vg(cmd, vp_new.vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
 
 	backup(vg);
 
@@ -126,6 +119,5 @@
 bad:
 	vg_release(vg);
 	unlock_vg(cmd, vp_new.vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_FAILED;
 }
--- LVM2/tools/vgextend.c	2009/07/08 14:33:17	1.45
+++ LVM2/tools/vgextend.c	2009/07/10 20:09:21	1.46
@@ -36,17 +36,11 @@
 	argc--;
 	argv++;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL,
 				READ_REQUIRE_RESIZEABLE);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
-		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 /********** FIXME
@@ -77,6 +71,5 @@
 
 error:
 	unlock_and_release_vg(cmd, vg, vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
 	return r;
 }


