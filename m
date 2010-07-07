From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2010 18:59:47 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgextend.c
Message-ID: <20100707185947.9483.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-07 18:59:46

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgextend.c 

Log message:
	Add warning to vgextend and pvchange if metadataignore given on cmdline.
	
	Warn the user then change the value of vg_mda_copies.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.384&r2=1.385
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/lib/metadata/metadata.c	2010/07/07 02:53:17	1.384
+++ LVM2/lib/metadata/metadata.c	2010/07/07 18:59:45	1.385
@@ -4396,8 +4396,13 @@
 	 * This does not guarantee this PV's ignore bits will be
 	 * preserved in future operations.
 	 */
-	if (!is_orphan(pv) && vg_mda_copies(pv->vg))
+	if (!is_orphan(pv) &&
+	    vg_mda_copies(pv->vg) != VGMETADATACOPIES_UNMANAGED) {
+		log_warn("WARNING: Changing preferred number of copies of VG %s "
+			 "metadata from %"PRIu32" to %"PRIu32, pv_vg_name(pv),
+			 vg_mda_copies(pv->vg), vg_mda_used_count(pv->vg));
 		vg_set_mda_copies(pv->vg, vg_mda_used_count(pv->vg));
+	}
 
 	return 1;
 }
--- LVM2/tools/vgextend.c	2009/11/01 19:51:55	1.55
+++ LVM2/tools/vgextend.c	2010/07/07 18:59:46	1.56
@@ -63,6 +63,15 @@
 	if (!vg_extend(vg, argc, argv, &pp))
 		goto_bad;
 
+	if (arg_count(cmd, metadataignore_ARG) &&
+	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+	    (vg_mda_copies(vg) != vg_mda_used_count(vg))) {
+		log_warn("WARNING: Changing preferred number of copies of VG %s "
+			 "metadata from %"PRIu32" to %"PRIu32, vg_name,
+			 vg_mda_copies(vg), vg_mda_used_count(vg));
+		vg_set_mda_copies(vg, vg_mda_used_count(vg));
+	}
+
 	/* ret > 0 */
 	log_verbose("Volume group \"%s\" will be extended by %d new "
 		    "physical volumes", vg_name, argc);


