From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 09:45:34 -0000
Subject: LVM2/lib/format_text archiver.c
Message-ID: <20090519094534.28044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 09:45:34

Modified files:
	lib/format_text: archiver.c 

Log message:
	vgcfgrestore should not quietly fail when backup file has missing PVs.
	
	(fixes previous commit: Fix segfault for vgcfgrestore on VG with missing PVs.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/format_text/archiver.c	2009/04/22 09:39:46	1.24
+++ LVM2/lib/format_text/archiver.c	2009/05/19 09:45:33	1.25
@@ -335,7 +335,7 @@
 			     const char *file)
 {
 	struct volume_group *vg;
-	int r = 0;
+	int missing_pvs, r = 0;
 
 	/*
 	 * Read in the volume group from the text file.
@@ -343,11 +343,12 @@
 	if (!(vg = backup_read_vg(cmd, vg_name, file)))
 		return_0;
 
-	/*
-	 * If PV is missing, there is already message from read above
-	 */
-	if (!vg_missing_pv_count(vg))
+	missing_pvs = vg_missing_pv_count(vg);
+	if (missing_pvs == 0)
 		r = backup_restore_vg(cmd, vg);
+	else
+		log_error("Cannot restore Volume Group %s with %i PVs "
+			  "marked as missing.", vg->name, missing_pvs);
 
 	vg_release(vg);
 	return r;


