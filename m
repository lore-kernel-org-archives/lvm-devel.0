From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:30:15 -0000
Subject: LVM2/lib format_text/text_label.c metadata/met ...
Message-ID: <20100628203015.13340.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:30:14

Modified files:
	lib/format_text: text_label.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add location independent flag and functions to ignore mdas.
	
	First we add a 'flags' field to the location independent
	metadata_area structure, and a MDA_IGNORE flag.  The
	mda_is_ignored and mda_set_ignored functions are added to
	manage the flag.  Adding the flag and functions gives a
	library interface to ignore metadata areas independent of
	the underlying location (disk, file, etc).  The location
	specific read/write functions must then handle the specifics
	of what this flag means to the location.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.346&r2=1.347
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.205&r2=1.206

--- LVM2/lib/format_text/text_label.c	2009/12/16 19:22:12	1.27
+++ LVM2/lib/format_text/text_label.c	2010/06/28 20:30:14	1.28
@@ -215,6 +215,7 @@
 
 	mdal->ops = mda_lists->raw_ops;
 	mdal->metadata_locn = mdac;
+	mdal->flags = 0;
 
 	mdac->area.dev = dev;
 	mdac->area.start = start;
--- LVM2/lib/metadata/metadata.c	2010/06/22 21:10:53	1.346
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:30:14	1.347
@@ -3855,6 +3855,19 @@
 	return pv_field(pv, pe_alloc_count);
 }
 
+unsigned mda_is_ignored(struct metadata_area *mda)
+{
+	return (mda->flags & MDA_IGNORED);
+}
+
+void mda_set_ignored(struct metadata_area *mda, int value)
+{
+	if (value)
+		mda->flags |= MDA_IGNORED;
+	else
+		mda->flags &= ~MDA_IGNORED;
+}
+
 uint32_t pv_mda_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
--- LVM2/lib/metadata/metadata.h	2010/05/24 15:32:20	1.205
+++ LVM2/lib/metadata/metadata.h	2010/06/28 20:30:14	1.206
@@ -158,12 +158,18 @@
 
 };
 
+#define MDA_IGNORED 0x00000001
+
 struct metadata_area {
 	struct dm_list list;
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
+	uint32_t flags;
 };
 
+unsigned mda_is_ignored(struct metadata_area *mda);
+void mda_set_ignored(struct metadata_area *mda, int value);
+
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
 #define seg_pe(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pe


