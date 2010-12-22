From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 15:44:10 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20101222154410.26105.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 15:44:09

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Remove check for existance of vg pointer
	
	Checking for vg being != NULL in this place is not needed.
	Pointer vg is already dereferced in this function above this code line.
	Also this internal function _read_pv is always called with valid 'vg' pointer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/lib/format_text/import_vsn1.c	2010/12/20 13:12:56	1.79
+++ LVM2/lib/format_text/import_vsn1.c	2010/12/22 15:44:09	1.80
@@ -257,14 +257,10 @@
 		log_verbose("Fixing up missing size (%s) "
 			    "for PV %s", display_size(fid->fmt->cmd, pv->size),
 			    pv_dev_name(pv));
-		if (vg) {
-			size = pv->pe_count * (uint64_t) vg->extent_size +
-			       pv->pe_start;
-			if (size > pv->size)
-				log_warn("WARNING: Physical Volume %s is too "
-					 "large for underlying device",
-					 pv_dev_name(pv));
-		}
+		size = pv->pe_count * (uint64_t) vg->extent_size + pv->pe_start;
+		if (size > pv->size)
+			log_warn("WARNING: Physical Volume %s is too large "
+				 "for underlying device", pv_dev_name(pv));
 	}
 
 	if (!alloc_pv_segment_whole_pv(mem, pv))


