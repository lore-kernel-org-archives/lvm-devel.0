From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 11:01:14 -0000
Subject: LVM2/lib/format_text archiver.c
Message-ID: <20120120110114.3118.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 11:01:13

Modified files:
	lib/format_text: archiver.c 

Log message:
	Thin until proper vgcfgrestore for thin is implementad, disable restore.
	
	Since it may probably do more harm to leave it enabled - add extra test
	for presence of thin volumes in VG, and in this case disable restore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/lib/format_text/archiver.c	2011/08/10 20:25:30	1.47
+++ LVM2/lib/format_text/archiver.c	2012/01/20 11:01:13	1.48
@@ -348,6 +348,7 @@
 {
 	struct volume_group *vg;
 	int missing_pvs, r = 0;
+	const struct lv_list *lvl;
 
 	/*
 	 * Read in the volume group from the text file.
@@ -355,6 +356,16 @@
 	if (!(vg = backup_read_vg(cmd, vg_name, file)))
 		return_0;
 
+	/* FIXME: Restore support is missing for now */
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_thin_type(lvl->lv)) {
+			log_error("Cannot restore Volume Group %s with "
+				  "thin logical volumes. "
+				  "(not yet supported).", vg->name);
+			r = 0;
+			goto out;
+		}
+
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
 		r = backup_restore_vg(cmd, vg);
@@ -362,6 +373,7 @@
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
 
+out:
 	release_vg(vg);
 	return r;
 }


