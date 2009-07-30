From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 18:40:23 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090730184023.7139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 18:40:22

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Revert 'preserve_pe_start' related code in _text_pv_setup
	
	If pv_setup was given a non-zero pe_start it would short-circuit
	establishing a default pv->pe_align.  pv->pe_align=0 would result
	in a divide by zero in _mda_setup().  'vgconvert -M2 $vgname' hit this.
	
	.pv_write still properly preserves pe_start if it was supplied.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1216&r2=1.1217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/WHATS_NEW	2009/07/30 17:45:28	1.1216
+++ LVM2/WHATS_NEW	2009/07/30 18:40:22	1.1217
@@ -1,7 +1,7 @@
 Version 2.02.51 - 
 ================================
   Add --dataalignmentoffset to pvcreate to shift start of aligned data area.
-  Preserve pe_start in .pv_setup and .pv_write if pe_start was supplied.
+  Preserve pe_start in .pv_write if pe_start was supplied.
   Fix _mda_setup() to not check first mda's size before pe_align rounding.
   Formalize pe_start policy as split between .pv_setup and .pv_write.
   Document -I option of clvmd in the man page.
--- LVM2/lib/format_text/format-text.c	2009/07/30 17:45:29	1.111
+++ LVM2/lib/format_text/format-text.c	2009/07/30 18:40:22	1.112
@@ -1735,10 +1735,8 @@
 		/* FIXME Default from config file? vgextend cmdline flag? */
 		pv->status |= ALLOCATABLE_PV;
 	} else {
-		if (pe_start) {
+		if (pe_start)
 			pv->pe_start = pe_start;
-			goto preserve_pe_start;
-		}
 
 		if (!data_alignment)
 			data_alignment = find_config_tree_int(pv->fmt->cmd,
@@ -1760,7 +1758,6 @@
 			return 0;
 		}
 
-	preserve_pe_start:
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,


