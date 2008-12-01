From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Dec 2008 20:14:33 -0000
Subject: LVM2 ./WHATS_NEW tools/vgcreate.c
Message-ID: <20081201201433.21067.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-01 20:14:33

Modified files:
	.              : WHATS_NEW 
	tools          : vgcreate.c 

Log message:
	Fix vgcreate race which could allow two parallel vgcreates to succeed,
	with the second vgcreate overwriting the first.
	
	Obtain lock before calling vg_create(), which checks for existence of vgname
	and fails if it already exists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1002&r2=1.1003
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2008/12/01 17:38:35	1.1002
+++ LVM2/WHATS_NEW	2008/12/01 20:14:33	1.1003
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix race in vgcreate that would result in second caller overwriting first.
   Fix uninitialised lv_count in vgdisplay -c.
   Don't skip updating pvid hash when lvmcache_info struct got swapped.
   Add tinfo to termcap search path for pld-linux.
--- LVM2/tools/vgcreate.c	2008/04/08 14:22:13	1.57
+++ LVM2/tools/vgcreate.c	2008/12/01 20:14:33	1.58
@@ -46,11 +46,22 @@
 	if (validate_vg_create_params(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
+	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+		log_error("Can't get lock for %s", vp_new.vg_name);
+		unlock_vg(cmd, VG_ORPHANS);
+		return ECMD_FAILED;
+	}
+
 	/* Create the new VG */
 	if (!(vg = vg_create(cmd, vp_new.vg_name, vp_new.extent_size,
 			     vp_new.max_pv, vp_new.max_lv, vp_new.alloc,
 			     argc - 1, argv + 1)))
-		return ECMD_FAILED;
+		goto bad;
 
 	if (vp_new.max_lv != vg->max_lv)
 		log_warn("WARNING: Setting maxlogicalvolumes to %d "
@@ -63,18 +74,18 @@
 	if (arg_count(cmd, addtag_ARG)) {
 		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
 			log_error("Failed to get tag");
-			return ECMD_FAILED;
+			goto bad;
 		}
 
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group format does not support tags");
-			return ECMD_FAILED;
+			goto bad;
 		}
 
 		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
 			log_error("Failed to add tag %s to volume group %s",
 				  tag, vp_new.vg_name);
-			return ECMD_FAILED;
+			goto bad;
 		}
 	}
 
@@ -88,28 +99,13 @@
 			clustered_message = "Non-clustered ";
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
-	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vp_new.vg_name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg)) {
-		unlock_vg(cmd, vp_new.vg_name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg)) {
-		unlock_vg(cmd, vp_new.vg_name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	unlock_vg(cmd, vp_new.vg_name);
@@ -121,4 +117,9 @@
 		  clustered_message, *clustered_message ? 'v' : 'V', vg->name);
 
 	return ECMD_PROCESSED;
+
+bad:
+	unlock_vg(cmd, vp_new.vg_name);
+	unlock_vg(cmd, VG_ORPHANS);
+	return ECMD_FAILED;
 }


