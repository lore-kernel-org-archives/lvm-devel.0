From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 17:18:09 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090730171809.18591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 17:18:08

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Formalize pe_start policy as split between .pv_setup and .pv_write.
	
	Document existing pe_start policy.
	Fix issue in _text_pv_setup() where existing pe_start case could have
	the pv->pe_start set to pv->pe_align even though pe_start shouldn't ever
	change.
	
	vgconvert and pvcreate have a facility to preserve the existing start
	of the on-disk data extents, known as pe_start.
	They indicate this by passing the existing value to the pvsetup function
	which must preserve it.
	
	This patch avoids one particular case where the value could get
	changed incorrectly now that the alignment settings are configurable.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1212&r2=1.1213
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW	2009/07/30 13:32:38	1.1212
+++ LVM2/WHATS_NEW	2009/07/30 17:18:03	1.1213
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Formalize pe_start policy as split between .pv_setup and .pv_write.
   Document -I option of clvmd in the man page.
   Fix configure script to handle multiple clvmd selections.
   Fix lvm2app.pc installation filename.
--- LVM2/lib/format_text/format-text.c	2009/07/15 20:02:47	1.106
+++ LVM2/lib/format_text/format-text.c	2009/07/30 17:18:08	1.107
@@ -1595,6 +1595,13 @@
 };
 
 /* pvmetadatasize in sectors */
+/*
+ * pe_start policy:
+ * - In cases where a pre-existing pe_start is provided (pvcreate --restorefile
+ *   and vgconvert): pe_start must not be changed (so pv->pe_start = pe_start).
+ * - In cases where pe_start is 0: leave pv->pe_start as 0 and defer the
+ *   setting of pv->pe_start to .pv_write
+ */
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size, unsigned long data_alignment,
@@ -1702,9 +1709,6 @@
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
-		if (pv->pe_start < pv->pe_align)
-			pv->pe_start = pv->pe_align;
-
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,


