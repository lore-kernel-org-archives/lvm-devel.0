From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:31:39 -0000
Subject: LVM2/lib format_text/format-text.c metadata/me ...
Message-ID: <20100628203139.14218.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:31:39

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add mda_locns_match() internal library function for mapping pv/device to VG mda.
	
	A metadata_area is defined independent of the location.  One downside
	is that there is no obvious mapping from a pv to an mda.  For a PV in
	a VG, we need a way to start with a PV and end up with an MDA, if we
	are to manage mdas starting with a device/pv.  This function provides
	us a way to go down the list of PVs on a VG, and identify which ones
	match a particular PV.
	
	I'm not entirely happy with this approach, but it does fit into the
	existing structures in a reasonable way.
	
	An alternative solution might be to refactor the VG - PV interface such
	that mdas are a list tied to a PV.  However, this seemed a bit tricky since
	a PV does not come into existence until after the list of mdas is
	constructed (see _vg_read() - we create a 'fid' and attach mdas to it,
	then we go through them and attach pvs).
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.347&r2=1.348
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.206&r2=1.207

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:31:18	1.128
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:31:38	1.129
@@ -121,6 +121,20 @@
 	return 0;
 }
 
+static unsigned _mda_locns_match_raw(struct metadata_area *mda1,
+				     struct metadata_area *mda2)
+{
+	struct mda_context *mda1c = (struct mda_context *) mda1->metadata_locn;
+	struct mda_context *mda2c = (struct mda_context *) mda2->metadata_locn;
+
+	if ((mda1c->area.dev == mda2c->area.dev) &&
+	    (mda1c->area.start == mda2c->area.start) &&
+	    (mda1c->area.size == mda2c->area.size))
+		return 1;
+
+	return 0;
+}
+
 /*
  * For circular region between region_start and region_start + region_size,
  * back up one SECTOR_SIZE from 'region_ptr' and return the value.
@@ -1732,6 +1746,7 @@
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
 	.pv_analyze_mda = _pv_analyze_mda_raw,
+	.mda_locns_match = _mda_locns_match_raw
 };
 
 /* pvmetadatasize in sectors */
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:30:14	1.347
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:31:38	1.348
@@ -3855,6 +3855,36 @@
 	return pv_field(pv, pe_alloc_count);
 }
 
+/*
+ * This function provides a way to answer the question on a format specific
+ * basis - does the format specfic context of these two metadata areas
+ * match?
+ *
+ * A metatdata_area is defined to be independent of the underlying context.
+ * This has the benefit that we can use the same abstraction to read disks
+ * (see _metadata_text_raw_ops) or files (see _metadata_text_file_ops).
+ * However, one downside is there is no format-independent way to determine
+ * whether a given metadata_area is attached to a specific device - in fact,
+ * it may not be attached to a device at all.
+ *
+ * Thus, LVM is structured such that an mda is not a member of struct
+ * physical_volume.  The location of the mda depends on whether
+ * the PV is in a volume group.  A PV not in a VG has an mda on the
+ * 'info->mda' list in lvmcache, while a PV in a VG has an mda on
+ * the vg->fid->metadata_areas list.  For further details, see _vg_read(),
+ * and the sequence of creating the format_instance with fid->metadata_areas
+ * list, as well as the construction of the VG, with list of PVs (comes
+ * after the construction of the fid and list of mdas).
+ */
+unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2)
+{
+	if (!mda1->ops->mda_locns_match || !mda2->ops->mda_locns_match ||
+	    mda1->ops->mda_locns_match != mda2->ops->mda_locns_match)
+		return 0;
+
+	return mda1->ops->mda_locns_match(mda1, mda2);
+}
+
 unsigned mda_is_ignored(struct metadata_area *mda)
 {
 	return (mda->flags & MDA_IGNORED);
--- LVM2/lib/metadata/metadata.h	2010/06/28 20:30:14	1.206
+++ LVM2/lib/metadata/metadata.h	2010/06/28 20:31:38	1.207
@@ -156,6 +156,12 @@
 	int (*pv_analyze_mda) (const struct format_type * fmt,
 			       struct metadata_area *mda);
 
+	/*
+	 * Do these two metadata_areas match with respect to their underlying
+	 * location?
+	 */
+	unsigned (*mda_locns_match)(struct metadata_area *mda1,
+				    struct metadata_area *mda2);
 };
 
 #define MDA_IGNORED 0x00000001
@@ -169,6 +175,7 @@
 
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, int value);
+unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev


