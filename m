From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:16:58 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20101129111658.15250.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:16:58

Modified files:
	lib/format_text: format-text.c 

Log message:
	Remove unused 'i' in _pv_analyze_mda_raw
	
	'i' is unused in the function - remove it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/lib/format_text/format-text.c	2010/10/26 09:13:13	1.148
+++ LVM2/lib/format_text/format-text.c	2010/11/29 11:16:58	1.149
@@ -173,7 +173,6 @@
 	uint64_t area_size;
 	uint64_t prev_sector, prev_sector2;
 	uint64_t latest_mrec_offset;
-	int i;
 	uint64_t offset;
 	uint64_t offset2;
 	size_t size;
@@ -214,7 +213,7 @@
 	offset = prev_sector;
 	size = SECTOR_SIZE;
 	offset2 = size2 = 0;
-	i = 0;
+
 	while (prev_sector != latest_mrec_offset) {
 		prev_sector2 = prev_sector;
 		prev_sector = _get_prev_sector_circular(area_start, area_size,


