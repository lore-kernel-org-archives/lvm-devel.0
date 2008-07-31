From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 13:07:02 -0000
Subject: LVM2 lib/config/config.c ./WHATS_NEW lib/forma ...
Message-ID: <20080731130702.8172.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 13:07:01

Modified files:
	lib/config     : config.c 
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Avoid looping forever in _pv_analyze_mda_raw used by pvck.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.940&r2=1.941
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/lib/config/config.c	2008/06/03 17:51:04	1.69
+++ LVM2/lib/config/config.c	2008/07/31 13:06:55	1.70
@@ -1276,7 +1276,7 @@
 	begin_count = _count_tokens(str, len, TOK_SECTION_B);
 	end_count = _count_tokens(str, len, TOK_SECTION_E);
 
-	if (begin_count && end_count && (begin_count - end_count == 0))
+	if (begin_count && end_count && (begin_count == end_count))
 		return 1;
 	else
 		return 0;
--- LVM2/WHATS_NEW	2008/07/31 13:03:01	1.940
+++ LVM2/WHATS_NEW	2008/07/31 13:07:01	1.941
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Avoid looping forever in _pv_analyze_mda_raw used by pvck.
   Change lvchange exit status to indicate if any part of the operation failed.
   Fix pvchange and pvremove to handle PVs without mdas.
   Refactor _text_pv_read and always return mda list if requested.
--- LVM2/lib/format_text/format-text.c	2008/07/31 10:50:18	1.92
+++ LVM2/lib/format_text/format-text.c	2008/07/31 13:07:01	1.93
@@ -139,7 +139,7 @@
 	struct raw_locn *rlocn;
 	uint64_t area_start;
 	uint64_t area_size;
-	uint64_t prev_sector;
+	uint64_t prev_sector, prev_sector2;
 	uint64_t latest_mrec_offset;
 	int i;
 	uint64_t offset;
@@ -184,8 +184,11 @@
 	offset2 = size2 = 0;
 	i = 0;
 	while (prev_sector != latest_mrec_offset) {
+		prev_sector2 = prev_sector;
 		prev_sector = _get_prev_sector_circular(area_start, area_size,
 							prev_sector);
+		if (prev_sector > prev_sector2)
+			goto_out;
 		/*
 		 * FIXME: for some reason, the whole metadata region from
 		 * area->start to area->start+area->size is not used.


