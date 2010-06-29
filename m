From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 22:41:30 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20100629224130.11131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 22:41:29

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Improve logging for setting --vgmetadatacopies.
	
	Example of logging:
	metadata/metadata.c:1127     Setting mda_copies = 3 on vg vgtest
	metadata/pv_manip.c:296         /dev/loop2 0:      0     25: NULL(0:0)
	metadata/pv_manip.c:296         /dev/loop3 0:      0     25: NULL(0:0)
	metadata/pv_manip.c:296         /dev/loop4 0:      0     25: NULL(0:0)
	metadata/metadata.c:1072     Adjusting ignored mdas on vg vgtest, vg_mda_used_count=5, vg_mda_copies=3
	metadata/metadata.c:1015     Setting ignore flag for 2 mdas on vg vgtest
	metadata/metadata.c:4151     Setting mda ignored flag for metadata_locn /dev/loop2.
	metadata/metadata.c:4151     Setting mda ignored flag for metadata_locn /dev/loop3.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.366&r2=1.367

--- LVM2/lib/metadata/metadata-exported.h	2010/06/29 21:32:44	1.159
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/29 22:41:28	1.160
@@ -886,7 +886,7 @@
 #define VGMETADATACOPIES_ALL UINT32_MAX
 #define VGMETADATACOPIES_UNMANAGED 0
 uint32_t vg_mda_copies(const struct volume_group *vg);
-int vg_set_mda_copies(struct volume_group *vg, uint32_t value);
+int vg_set_mda_copies(struct volume_group *vg, uint32_t copies);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
--- LVM2/lib/metadata/metadata.c	2010/06/29 22:37:32	1.366
+++ LVM2/lib/metadata/metadata.c	2010/06/29 22:41:28	1.367
@@ -1011,6 +1011,8 @@
 {
 	struct metadata_area *mda;
 
+	log_verbose("Setting ignore flag for %"PRIu32" mdas on vg %s",
+		    num_to_ignore, vg->name);
 	if (!num_to_ignore)
 		return 1;
 	/* FIXME: flip bits on random mdas */
@@ -1031,6 +1033,8 @@
 {
 	struct metadata_area *mda, *tmda;
 
+	log_verbose("Clearing ignore flag for %"PRIu32" mdas on vg %s",
+		    num_to_unignore, vg->name);
 	if (!num_to_unignore)
 		return 1;
 	/* FIXME: flip bits on random mdas */
@@ -1063,6 +1067,9 @@
 	int ret = 1;
 
 	mda_copies = vg_mda_used_count(vg);
+	log_verbose("Adjusting ignored mdas on vg %s, vg_mda_used_count=%"
+		    PRIu32", vg_mda_copies=%"PRIu32,
+		    vg->name, mda_copies, vg_mda_copies(vg));
 	if (vg->mda_copies == VGMETADATACOPIES_UNMANAGED)
 		goto skip_adjust;
 
@@ -1108,14 +1115,16 @@
 	return vg->mda_copies;
 }
 
-int vg_set_mda_copies(struct volume_group *vg, uint32_t value)
+int vg_set_mda_copies(struct volume_group *vg, uint32_t copies)
 {
 	/* FIXME: add checks, etc, and set the value */
 	/*
 	 * FIXME: Before we set a larger value, we may need to
 	 * enable some mdas on PVS
 	 */
-	vg->mda_copies = value;
+	vg->mda_copies = copies;
+	log_verbose("Setting mda_copies = %"PRIu32" on vg %s",
+		    copies, vg->name);
 	return 1;
 }
 


