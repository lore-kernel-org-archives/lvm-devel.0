From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:39:18 -0000
Subject: LVM2/lib/metadata metadata.h thin_manip.c
Message-ID: <20111003183918.28055.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:39:18

Modified files:
	lib/metadata   : metadata.h thin_manip.c 

Log message:
	Add simple function for lookup of some free device_id
	
	Initial simple implementation for finding some free device_id.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.256&r2=1.257
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/metadata/metadata.h	2011/09/09 01:15:18	1.256
+++ LVM2/lib/metadata/metadata.h	2011/10/03 18:39:17	1.257
@@ -374,6 +374,9 @@
 /* Find pool LV segment given a thin pool data or metadata segment. */
 struct lv_segment *find_pool_seg(const struct lv_segment *seg);
 
+/* Find some unused device_id for thin pool LV segment. */
+uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg);
+
 /*
  * Remove a dev_dir if present.
  */
--- LVM2/lib/metadata/thin_manip.c	2011/09/09 01:15:18	1.4
+++ LVM2/lib/metadata/thin_manip.c	2011/10/03 18:39:17	1.5
@@ -80,3 +80,40 @@
 
         return pool_seg;
 }
+
+/*
+ * Find a free device_id for given thin_pool segment.
+ *
+ * \return
+ * Free device id, or 0 if free device_id is not found.
+ *
+ * FIXME: Improve naive search and keep the value cached
+ * and updated during VG lifetime (so no const for lv_segment)
+ */
+uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
+{
+	uint32_t dev_id, max_id = 0;
+	struct dm_list *h;
+
+	if (!seg_is_thin_pool(thin_pool_seg)) {
+		log_error("Segment in %s is not a thin pool segment.",
+			  pool_seg->lv->name);
+		return 0;
+	}
+
+	dm_list_iterate(h, &thin_pool_seg->lv->segs_using_this_lv) {
+		dev_id = dm_list_item(h, struct seg_list)->seg->device_id;
+		if (dev_id > max_id)
+			max_id = dev_id;
+	}
+
+	if (++max_id >= (1 << 24)) {
+		// FIXME: try to find empty holes....
+		log_error("Free device_id exhausted...");
+		return 0;
+	}
+
+	log_debug("Found free pool device_id %u.", max_id);
+
+	return max_id;
+}


