From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Feb 2011 17:08:09 -0000
Subject: LVM2/tools pvresize.c
Message-ID: <20110228170809.31229.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-28 17:08:09

Modified files:
	tools          : pvresize.c 

Log message:
	Add a hint for manual revert if there's an error in pv_write, vg_write, vg_commit for pvresize.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/tools/pvresize.c	2011/02/28 13:19:03	1.42
+++ LVM2/tools/pvresize.c	2011/02/28 17:08:09	1.43
@@ -35,6 +35,7 @@
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = pv_vg_name(pv);
 	struct volume_group *old_vg = vg;
+	int vg_needs_pv_write = 0;
 
 	if (is_orphan_vg(vg_name)) {
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
@@ -100,7 +101,8 @@
 
 	/* Write PV label only if this an orphan PV or it has 2nd mda. */
 	if ((is_orphan_vg(vg_name) ||
-	    fid_get_mda_indexed(vg->fid, (const char *) &pv->id, ID_LEN, 1)) &&
+	     (vg_needs_pv_write = (fid_get_mda_indexed(vg->fid,
+			(const char *) &pv->id, ID_LEN, 1) != NULL))) &&
 	    !pv_write(cmd, pv, 1)) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
@@ -120,6 +122,9 @@
 	r = 1;
 
 out:
+	if (!r && vg_needs_pv_write)
+		log_error("Use pvcreate and vgcfgrestore "
+			  "to repair from archived metadata.");
 	unlock_vg(cmd, vg_name);
 	if (!old_vg)
 		free_vg(vg);


