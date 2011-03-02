From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 2 Mar 2011 10:19:15 -0000
Subject: LVM2/lib/format_text format-text.c format-text.h
Message-ID: <20110302101915.13225.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-02 10:19:14

Modified files:
	lib/format_text: format-text.c format-text.h 

Log message:
	Make add_metadata_area_to_pv/remove_metadata_area_from_pv static.
	
	No need to put these in format-text.h, it's not used anywhere else actually.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/format_text/format-text.c	2011/02/28 17:05:48	1.171
+++ LVM2/lib/format_text/format-text.c	2011/03/02 10:19:14	1.172
@@ -1848,11 +1848,11 @@
 	return 1;
 }
 
-int add_metadata_area_to_pv(struct physical_volume *pv,
-			    unsigned mda_index,
-			    uint64_t mda_start,
-			    uint64_t mda_size,
-			    unsigned mda_ignored)
+static int _add_metadata_area_to_pv(struct physical_volume *pv,
+				    unsigned mda_index,
+				    uint64_t mda_start,
+				    uint64_t mda_size,
+				    unsigned mda_ignored)
 {
 	struct metadata_area *mda;
 	struct mda_context *mdac;
@@ -2101,8 +2101,8 @@
 		}
 
 		/* Finally, add new metadata area to PV's format instance. */
-		if (!add_metadata_area_to_pv(pv, mda_index, mda_start,
-					     mda_size, mda_ignored))
+		if (!_add_metadata_area_to_pv(pv, mda_index, mda_start,
+					      mda_size, mda_ignored))
 			return_0;
 	}
 
@@ -2114,8 +2114,8 @@
 	return 0;
 }
 
-int remove_metadata_area_from_pv(struct physical_volume *pv,
-				 unsigned mda_index)
+static int _remove_metadata_area_from_pv(struct physical_volume *pv,
+					 unsigned mda_index)
 {
 	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
 		log_error(INTERNAL_ERROR "can't remove metadata area with "
@@ -2134,7 +2134,7 @@
 					 struct physical_volume *pv,
 					 unsigned mda_index)
 {
-	return remove_metadata_area_from_pv(pv, mda_index);
+	return _remove_metadata_area_from_pv(pv, mda_index);
 }
 
 static int _text_pv_resize(const struct format_type *fmt,
--- LVM2/lib/format_text/format-text.h	2011/02/21 12:17:54	1.31
+++ LVM2/lib/format_text/format-text.h	2011/03/02 10:19:14	1.32
@@ -55,14 +55,6 @@
 int add_da(struct dm_pool *mem, struct dm_list *das,
 	   uint64_t start, uint64_t size);
 void del_das(struct dm_list *das);
-
-int add_metadata_area_to_pv(struct physical_volume *pv,
-			    unsigned mda_index,
-			    uint64_t mda_start,
-			    uint64_t mda_size,
-			    unsigned mda_ignored);
-int remove_metadata_area_from_pv(struct physical_volume *pv,
-				 unsigned mda_index);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);


