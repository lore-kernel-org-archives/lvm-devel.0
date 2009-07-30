From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 17:42:36 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090730174236.27606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 17:42:34

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Preserve pe_start in .pv_setup and .pv_write if pe_start was supplied.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1214&r2=1.1215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/WHATS_NEW	2009/07/30 17:19:31	1.1214
+++ LVM2/WHATS_NEW	2009/07/30 17:42:33	1.1215
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Preserve pe_start in .pv_setup and .pv_write if pe_start was supplied.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Formalize pe_start policy as split between .pv_setup and .pv_write.
   Document -I option of clvmd in the man page.
--- LVM2/lib/format_text/format-text.c	2009/07/30 17:41:01	1.109
+++ LVM2/lib/format_text/format-text.c	2009/07/30 17:42:33	1.110
@@ -1368,12 +1368,17 @@
 	else
 		dm_list_init(&info->das);
 
+	if (pv->pe_start) {
+		log_very_verbose("%s: preserving pe_start=%lu",
+				 pv_dev_name(pv), pv->pe_start);
+		goto preserve_pe_start;
+	}
+
 	/*
 	 * If pe_start is still unset, set it to first aligned
 	 * sector after any metadata areas that begin before pe_start.
 	 */
-	if (!pv->pe_start)
-		pv->pe_start = pv->pe_align;
+	pv->pe_start = pv->pe_align;
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
@@ -1389,6 +1394,8 @@
 				pv->pe_start += pv->pe_align - adjustment;
 		}
 	}
+
+ preserve_pe_start:
 	if (!add_da
 	    (NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
 		return_0;
@@ -1700,8 +1707,10 @@
 		/* FIXME Default from config file? vgextend cmdline flag? */
 		pv->status |= ALLOCATABLE_PV;
 	} else {
-		if (pe_start)
+		if (pe_start) {
 			pv->pe_start = pe_start;
+			goto preserve_pe_start;
+		}
 
 		if (!data_alignment)
 			data_alignment = find_config_tree_int(pv->fmt->cmd,
@@ -1714,6 +1723,7 @@
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
+	preserve_pe_start:
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,


