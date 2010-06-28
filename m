From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:38:41 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100628203841.19944.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:38:40

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Ensure fid mda lists are populated correctly during vgextend.
	
	The vgextend path calls add_pv_to_vg().  Inside add_pv_to_vg(),
	we must ensure we pass the correct mdas list into pv_setup(), as
	copies of mdas are placed on the vg->fid list.  If we don't place
	the mdas on the correct vg->fid list, the various counts may be
	incorrect and the metadata balance algorithm will not work when
	called from vg_write() path.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.360&r2=1.361

--- LVM2/lib/metadata/metadata.c	2010/06/28 20:37:54	1.360
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:38:39	1.361
@@ -174,6 +174,7 @@
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
 	char uuid[64] __attribute((aligned(8)));
+	struct dm_list *mdas;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -217,9 +218,24 @@
 	 */
 	pv->pe_alloc_count = 0;
 
+	/*
+	 * FIXME: this does not work entirely correctly in the case where a PV
+	 * has 2 mdas and only one is ignored; ideally all non-ignored mdas
+	 * should be placed on metadata_areas list and ignored on the
+	 * metadata_areas_ignored list; however this requires another
+	 * fairly complex refactoring to remove the 'mdas' parameter from both
+	 * pv_setup and pv_write.  For now, we only put ignored mdas on the
+	 * metadata_areas_ignored list if all mdas in the PV are ignored;
+	 * otherwise, we use the non-ignored list.
+	 */
+	if (!pv_mda_used_count(pv))
+		mdas = &fid->metadata_areas_ignored;
+	else
+		mdas = &fid->metadata_areas_in_use;
+
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
 				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
-				     &fid->metadata_areas_in_use, pv, vg)) {
+				     mdas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
 		return 0;


