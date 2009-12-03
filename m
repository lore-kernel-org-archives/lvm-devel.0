From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Dec 2009 19:20:49 -0000
Subject: LVM2 ./WHATS_NEW tools/vgcreate.c
Message-ID: <20091203192049.26423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-03 19:20:49

Modified files:
	.              : WHATS_NEW 
	tools          : vgcreate.c 

Log message:
	Print error if VG already exist.
	
	This test have to be moved because of new vg read error handling.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1338&r2=1.1339
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2009/12/03 19:18:33	1.1338
+++ LVM2/WHATS_NEW	2009/12/03 19:20:48	1.1339
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix error message if VG already exist in vgcreate.
   Fix tools to use log_error when stopped by user.
   Fix lvcreate --readahead.
   Fix clvmd memory leak in lv_info_by_lvid.
--- LVM2/tools/vgcreate.c	2009/11/01 20:05:17	1.75
+++ LVM2/tools/vgcreate.c	2009/12/03 19:20:49	1.76
@@ -55,8 +55,13 @@
 
 	/* Create the new VG */
 	vg = vg_create(cmd, vp_new.vg_name);
-	if (vg_read_error(vg))
-		goto_bad;
+	if (vg_read_error(vg)) {
+		if (vg_read_error(vg) == FAILED_EXIST)
+			log_error("A volume group called %s already exists.", vp_new.vg_name);
+		else
+			log_error("Can't get lock for %s.", vp_new.vg_name);
+		goto bad;
+	}
 
 	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
 	    !vg_set_max_lv(vg, vp_new.max_lv) ||


