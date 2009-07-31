From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 31 Jul 2009 14:23:07 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20090731142307.31623.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-31 14:23:07

Modified files:
	lib/format_text: format-text.c 

Log message:
	Fix compile warnings from recently added log_very_verbose() in _text_pv_write()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/lib/format_text/format-text.c	2009/07/30 21:15:17	1.113
+++ LVM2/lib/format_text/format-text.c	2009/07/31 14:23:06	1.114
@@ -1427,8 +1427,8 @@
 				if (adjustment)
 					pv->pe_start += pv->pe_align - adjustment;
 
-				log_very_verbose("%s: setting pe_start=%lu "
-					 "(orig_pe_start=%lu, "
+				log_very_verbose("%s: setting pe_start=%" PRIu64
+					 " (orig_pe_start=%" PRIu64 ", "
 					 "pe_align=%lu, pe_align_offset=%lu, "
 					 "adjustment=%" PRIu64 ")",
 					 pv_dev_name(pv), pv->pe_start,


