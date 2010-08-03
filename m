From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 3 Aug 2010 18:19:44 -0000
Subject: LVM2 lib/format_text/format-text.c ./WHATS_NEW
Message-ID: <20100803181944.1724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-03 18:19:43

Modified files:
	lib/format_text: format-text.c 
	.              : WHATS_NEW 

Log message:
	Avoid changing aligned pe_start as a side-effect of very verbose logging.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1693&r2=1.1694

--- LVM2/lib/format_text/format-text.c	2010/07/09 15:34:44	1.141
+++ LVM2/lib/format_text/format-text.c	2010/08/03 18:19:42	1.142
@@ -1498,7 +1498,7 @@
 				adjustment =
 				(pv->pe_start - pv->pe_align_offset) % pv->pe_align;
 				if (adjustment)
-					pv->pe_start += pv->pe_align - adjustment;
+					pv->pe_start += (pv->pe_align - adjustment);
 
 				log_very_verbose("%s: setting pe_start=%" PRIu64
 					 " (orig_pe_start=%" PRIu64 ", "
@@ -1506,7 +1506,7 @@
 					 "adjustment=%" PRIu64 ")",
 					 pv_dev_name(pv), pv->pe_start,
 					 (adjustment ?
-					  pv->pe_start -= pv->pe_align - adjustment :
+					  pv->pe_start - (pv->pe_align - adjustment) :
 					  pv->pe_start),
 					 pv->pe_align, pv->pe_align_offset, adjustment);
 			}
--- LVM2/WHATS_NEW	2010/08/03 13:24:07	1.1693
+++ LVM2/WHATS_NEW	2010/08/03 18:19:43	1.1694
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Avoid changing aligned pe_start as a side-effect of very verbose logging.
   Fix 'void*' arithmetic warnings in dbg_malloc.c.
   Fix 'void*' arithmetic warning in some functions from libdm-iface.c.
   Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().


