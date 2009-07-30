From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 21:15:19 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090730211519.2838.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 21:15:18

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Disable the "new pe_start policy"
	
	Documented which use-cases force the reinstatement of the nuanced
	handling of pe_start.  As soon as orphan PVs are eliminated much of this
	will no longer be a concern ('preserve_pe_start' can be reenabled in
	.pv_setup).
	
	Added defensive 'if (pv->pe_align)' check in _text_pv_write()'s pe_start
	loop.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1217&r2=1.1218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/WHATS_NEW	2009/07/30 18:40:22	1.1217
+++ LVM2/WHATS_NEW	2009/07/30 21:15:17	1.1218
@@ -1,9 +1,7 @@
 Version 2.02.51 - 
 ================================
   Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
-  Preserve pe_start in .pv_write if pe_start was supplied.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
-  Formalize pe_start policy as split between .pv_setup and .pv_write.
   Document -I option of clvmd in the man page.
   Fix configure script to handle multiple clvmd selections.
   Fix lvm2app.pc installation filename.
--- LVM2/lib/format_text/format-text.c	2009/07/30 18:40:22	1.112
+++ LVM2/lib/format_text/format-text.c	2009/07/30 21:15:17	1.113
@@ -1337,6 +1337,7 @@
 	char buf[MDA_HEADER_SIZE] __attribute((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
 	uint64_t adjustment;
+	struct data_area_list *da;
 
 	/* FIXME Test mode don't update cache? */
 
@@ -1373,24 +1374,42 @@
 		dm_list_init(&info->mdas);
 	}
 
-	if (info->das.n)
+	/*
+	 * If no pe_start supplied but PV already exists,
+	 * get existing value; use-cases include:
+	 * - pvcreate on PV without prior pvremove
+	 * - vgremove on VG with PV(s) that have pe_start=0 (hacked cfg)
+	 */
+	if (info->das.n) {
+		if (!pv->pe_start)
+			dm_list_iterate_items(da, &info->das)
+				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 		del_das(&info->das);
-	else
+	} else
 		dm_list_init(&info->das);
 
+#if 0
+	/*
+	 * FIXME: ideally a pre-existing pe_start seen in .pv_write
+	 * would always be preserved BUT 'pvcreate on PV without prior pvremove'
+	 * could easily cause the pe_start to overlap with the first mda!
+	 */
 	if (pv->pe_start) {
 		log_very_verbose("%s: preserving pe_start=%lu",
 				 pv_dev_name(pv), pv->pe_start);
 		goto preserve_pe_start;
 	}
+#endif
 
 	/*
 	 * If pe_start is still unset, set it to first aligned
 	 * sector after any metadata areas that begin before pe_start.
 	 */
-	pv->pe_start = pv->pe_align;
-	if (pv->pe_align_offset)
-		pv->pe_start += pv->pe_align_offset;
+	if (!pv->pe_start) {
+		pv->pe_start = pv->pe_align;
+		if (pv->pe_align_offset)
+			pv->pe_start += pv->pe_align_offset;
+	}
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
@@ -1402,11 +1421,14 @@
 			pv->pe_start = (mdac->area.start + mdac->area.size)
 			    >> SECTOR_SHIFT;
 			/* Adjust pe_start to: (N * pe_align) + pe_align_offset */
-			adjustment =
+			if (pv->pe_align) {
+				adjustment =
 				(pv->pe_start - pv->pe_align_offset) % pv->pe_align;
-			if (adjustment)
-				pv->pe_start += pv->pe_align - adjustment;
-			log_very_verbose("%s: setting pe_start=%lu (orig_pe_start=%lu, "
+				if (adjustment)
+					pv->pe_start += pv->pe_align - adjustment;
+
+				log_very_verbose("%s: setting pe_start=%lu "
+					 "(orig_pe_start=%lu, "
 					 "pe_align=%lu, pe_align_offset=%lu, "
 					 "adjustment=%" PRIu64 ")",
 					 pv_dev_name(pv), pv->pe_start,
@@ -1414,6 +1436,7 @@
 					  pv->pe_start -= pv->pe_align - adjustment :
 					  pv->pe_start),
 					 pv->pe_align, pv->pe_align_offset, adjustment);
+			}
 		}
 	}
 	if (pv->pe_start >= pv->size) {
@@ -1422,7 +1445,7 @@
 		return 0;
 	}
 
- preserve_pe_start:
+	/* FIXME: preserve_pe_start: */
 	if (!add_da
 	    (NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
 		return_0;
@@ -1635,7 +1658,7 @@
 
 /* pvmetadatasize in sectors */
 /*
- * pe_start policy:
+ * pe_start goal: FIXME -- reality of .pv_write complexity undermines this goal
  * - In cases where a pre-existing pe_start is provided (pvcreate --restorefile
  *   and vgconvert): pe_start must not be changed (so pv->pe_start = pe_start).
  * - In cases where pe_start is 0: leave pv->pe_start as 0 and defer the
@@ -1758,6 +1781,18 @@
 			return 0;
 		}
 
+		/*
+		 * This initialization has a side-effect of allowing
+		 * orphaned PVs to be created with the proper alignment.
+		 * Setting pv->pe_start here circumvents .pv_write's
+		 * "pvcreate on PV without prior pvremove" retreival of
+		 * the PV's previous pe_start.
+		 * - Without this you get actual != expected pe_start
+		 *   failures in the testsuite.
+		 */
+		if (!pe_start && pv->pe_start < pv->pe_align)
+			pv->pe_start = pv->pe_align;
+
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,


