From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:33:24 -0000
Subject: LVM2/lib format1/format1.c format_pool/format_ ...
Message-ID: <20100628203324.15377.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:33:23

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	lib/report     : report.c 

Log message:
	Add metadata_areas_ignored list and functions to manage ignored mdas.
	
	Add a second mda list, metadata_areas_ignored to fid, and a couple
	functions, fid_add_mda() and fid_add_mdas() to help manage the lists.
	
	These functions are needed to properly count the ignored mdas and
	manage the lists attached to the 'fid' and ultimately the 'vg'.
	
	Ensure metadata_areas_ignored is initialized in other formats, even
	if the list is never used.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.350&r2=1.351
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.209&r2=1.210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/lib/format1/format1.c	2010/06/28 20:32:44	1.117
+++ LVM2/lib/format1/format1.c	2010/06/28 20:33:22	1.118
@@ -464,6 +464,7 @@
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas_in_use);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
--- LVM2/lib/format_pool/format_pool.c	2010/06/28 20:32:46	1.28
+++ LVM2/lib/format_pool/format_pool.c	2010/06/28 20:33:23	1.29
@@ -263,6 +263,7 @@
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas_in_use);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
--- LVM2/lib/format_text/format-text.c	2010/06/28 20:32:46	1.131
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:33:23	1.132
@@ -1209,6 +1209,7 @@
 
 	fid.fmt = fmt;
 	dm_list_init(&fid.metadata_areas_in_use);
+	dm_list_init(&fid.metadata_areas_ignored);
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
@@ -1915,6 +1916,7 @@
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas_in_use);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	if (!vgname) {
 		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
--- LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:32:46	1.153
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:33:23	1.154
@@ -215,7 +215,14 @@
 
 struct format_instance {
 	const struct format_type *fmt;
-	struct dm_list metadata_areas_in_use;	/* e.g. metadata locations */
+	/*
+	 * Each mda in a vg is on exactly one of the below lists.
+	 * MDAs on the 'in_use' list will be read from / written to
+	 * disk, while MDAs on the 'ignored' list will not be read
+	 * or written to.
+	 */
+	struct dm_list metadata_areas_in_use;
+	struct dm_list metadata_areas_ignored;
 	void *private;
 };
 
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:32:46	1.350
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:33:23	1.351
@@ -3855,6 +3855,29 @@
 	return pv_field(pv, pe_alloc_count);
 }
 
+void fid_add_mda(struct format_instance *fid, struct metadata_area *mda)
+{
+	if (mda_is_ignored(mda))
+		dm_list_add(&fid->metadata_areas_ignored,
+			    &mda->list);
+	else
+		dm_list_add(&fid->metadata_areas_in_use,
+			    &mda->list);
+}
+
+int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas)
+{
+	struct metadata_area *mda, *mda_new;
+
+	dm_list_iterate_items(mda, mdas) {
+		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
+		if (!mda_new)
+			return_0;
+		fid_add_mda(fid, mda_new);
+	}
+	return 1;
+}
+
 /*
  * Copy constructor for a metadata_area.
  */
--- LVM2/lib/metadata/metadata.h	2010/06/28 20:32:46	1.209
+++ LVM2/lib/metadata/metadata.h	2010/06/28 20:33:23	1.210
@@ -183,6 +183,8 @@
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, int value);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
+void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
+int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
--- LVM2/lib/report/report.c	2010/06/28 20:32:47	1.118
+++ LVM2/lib/report/report.c	2010/06/28 20:33:23	1.119
@@ -1127,6 +1127,7 @@
 /* necessary for displaying something for PVs not belonging to VG */
 static struct format_instance _dummy_fid = {
 	.metadata_areas_in_use = { &(_dummy_fid.metadata_areas_in_use), &(_dummy_fid.metadata_areas_in_use) },
+	.metadata_areas_ignored = { &(_dummy_fid.metadata_areas_ignored), &(_dummy_fid.metadata_areas_ignored) },
 };
 
 static struct volume_group _dummy_vg = {


