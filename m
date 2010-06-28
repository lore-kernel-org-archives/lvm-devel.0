From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:36:57 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20100628203657.18117.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:36:56

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add vg get/set methods for VG metadata copies.
	
	This patch adds the get and partially implemented set function.
	The 'set' function should probably ignore or un-ignore metadata areas
	based on new values.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.358&r2=1.359

--- LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:36:37	1.156
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:36:56	1.157
@@ -882,6 +882,8 @@
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
+uint32_t vg_mda_copies(const struct volume_group *vg);
+int vg_set_mda_copies(struct volume_group *vg, uint32_t value);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:36:37	1.358
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:36:56	1.359
@@ -989,6 +989,22 @@
 	return 1;
 }
 
+uint32_t vg_mda_copies(const struct volume_group *vg)
+{
+	return vg->mda_copies;
+}
+
+int vg_set_mda_copies(struct volume_group *vg, uint32_t value)
+{
+	/* FIXME: add checks, etc, and set the value */
+	/*
+	 * FIXME: Before we set a larger value, we may need to
+	 * enable some mdas on PVS
+	 */
+	vg->mda_copies = value;
+	return 1;
+}
+
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;


