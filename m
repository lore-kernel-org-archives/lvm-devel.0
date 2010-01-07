From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:46:52 -0000
Subject: LVM2/lib mirror/mirrored.c striped/striped.c
Message-ID: <20100107144652.29933.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:46:52

Modified files:
	lib/mirror     : mirrored.c 
	lib/striped    : striped.c 

Log message:
	Use macro outsize() with check for error return value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/mirror/mirrored.c	2009/11/18 16:48:10	1.65
+++ LVM2/lib/mirror/mirrored.c	2010/01/07 14:46:51	1.66
@@ -149,8 +149,8 @@
 {
 	outf(f, "mirror_count = %u", seg->area_count);
 	if (seg->status & PVMOVE)
-		out_size(f, (uint64_t) seg->extents_copied * seg->lv->vg->extent_size,
-			 "extents_moved = %" PRIu32, seg->extents_copied);
+		outsize(f, (uint64_t) seg->extents_copied * seg->lv->vg->extent_size,
+			"extents_moved = %" PRIu32, seg->extents_copied);
 	if (seg->log_lv)
 		outf(f, "mirror_log = \"%s\"", seg->log_lv->name);
 	if (seg->region_size)
--- LVM2/lib/striped/striped.c	2009/12/16 19:22:12	1.30
+++ LVM2/lib/striped/striped.c	2010/01/07 14:46:52	1.31
@@ -98,8 +98,8 @@
 	     (seg->area_count == 1) ? "\t# linear" : "");
 
 	if (seg->area_count > 1)
-		out_size(f, (uint64_t) seg->stripe_size,
-			 "stripe_size = %u", seg->stripe_size);
+		outsize(f, (uint64_t) seg->stripe_size,
+			"stripe_size = %u", seg->stripe_size);
 
 	return out_areas(f, seg, "stripe");
 }


