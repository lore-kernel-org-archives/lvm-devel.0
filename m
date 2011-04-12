From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 12 Apr 2011 22:04:05 -0000
Subject: LVM2/lib/metadata pv_manip.c
Message-ID: <20110412220405.29632.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-04-12 22:04:04

Modified files:
	lib/metadata   : pv_manip.c 

Log message:
	Use uint32_t rather than uint64_t.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/lib/metadata/pv_manip.c	2011/04/12 21:59:01	1.29
+++ LVM2/lib/metadata/pv_manip.c	2011/04/12 22:04:04	1.30
@@ -193,7 +193,7 @@
 {
 	uint64_t discard_offset;
 	uint64_t pe_start = peg->pv->pe_start;
-	uint64_t discard_area_reduction = area_reduction;
+	uint32_t discard_area_reduction = area_reduction;
 
 	if (!peg->lvseg) {
 		log_error("release_pv_segment with unallocated segment: "


