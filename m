From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:39 -0400
Subject: [PATCH 08/38] Add mda_locn_match() internal library function for mapping pv/device to VG mda.
In-Reply-To: <1277520789-6808-8-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
---
 lib/format_text/format-text.c |   15 +++++++++++++++
 lib/metadata/metadata.c       |   30 ++++++++++++++++++++++++++++++
 lib/metadata/metadata.h       |    7 +++++++
 3 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 723dfb9..901fa2d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -121,6 +121,20 @@ static int _mda_in_vg_raw(struct format_instance *fid __attribute((unused)),
 	return 0;
 }
 
+static int _mda_locn_match_raw(struct metadata_area *mda1,
+			       struct metadata_area *mda2)
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
@@ -1730,6 +1744,7 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
 	.pv_analyze_mda = _pv_analyze_mda_raw,
+	.mda_locn_match = _mda_locn_match_raw
 };
 
 /* pvmetadatasize in sectors */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9764fb7..7af3dd2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3855,6 +3855,36 @@ uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
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
+int mda_locn_match(struct metadata_area *mda1, struct metadata_area *mda2)
+{
+	if (!mda1->ops->mda_locn_match || !mda2->ops->mda_locn_match ||
+	    mda1->ops->mda_locn_match != mda2->ops->mda_locn_match)
+		return 0;
+
+	return mda1->ops->mda_locn_match(mda1, mda2);
+}
+
 int mda_is_ignored(struct metadata_area *mda)
 {
 	return (mda->flags & MDA_IGNORED);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 71c562a..6f6236f 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -156,6 +156,12 @@ struct metadata_area_ops {
 	int (*pv_analyze_mda) (const struct format_type * fmt,
 			       struct metadata_area *mda);
 
+	/*
+	 * Do these two metadata_areas match with respect to their underlying
+	 * location?
+	 */
+	int (*mda_locn_match)(struct metadata_area *mda1,
+			      struct metadata_area *mda2);
 };
 
 #define MDA_IGNORED 0x00000001
@@ -169,6 +175,7 @@ struct metadata_area {
 
 int mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, int value);
+int mda_locn_match(struct metadata_area *mda1, struct metadata_area *mda2);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
-- 
1.6.0.6


