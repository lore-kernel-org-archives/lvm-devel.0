From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:34:41 -0000
Subject: LVM2/lib/metadata metadata.c metadata.h
Message-ID: <20100628203441.16223.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:34:40

Modified files:
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add mdas_empty_or_ignored() helper function.
	
	Add a helper function to consolidate checking for an empty mdas list
	or ignored mdas.  Ignored mdas should behave almost identically to
	an empty mda list - the metadata areas should not be read or written
	to.  This function will make it easier to implement metadata balancing
	and easier to track pvs with an empty mda list or ignored mdas.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.352&r2=1.353
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.210&r2=1.211

--- LVM2/lib/metadata/metadata.c	2010/06/28 20:33:44	1.352
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:34:40	1.353
@@ -4032,6 +4032,19 @@
 	return 1;
 }
 
+int mdas_empty_or_ignored(struct dm_list *mdas)
+{
+	struct metadata_area *mda;
+
+	if (!dm_list_size(mdas))
+		return 1;
+	dm_list_iterate_items(mda, mdas) {
+		if (mda_is_ignored(mda))
+			return 1;
+	}
+	return 0;
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
--- LVM2/lib/metadata/metadata.h	2010/06/28 20:33:23	1.210
+++ LVM2/lib/metadata/metadata.h	2010/06/28 20:34:40	1.211
@@ -185,6 +185,7 @@
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
 void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
 int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);
+int mdas_empty_or_ignored(struct dm_list *mdas);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev


