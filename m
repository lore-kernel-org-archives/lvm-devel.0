From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:25:09 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111028202509.2474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:25:08

Modified files:
	lib/thin       : thin.c 

Log message:
	Thin output data_block_size via outsize
	
	Use outsize to get nice size hint.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/lib/thin/thin.c	2011/10/22 16:45:25	1.25
+++ LVM2/lib/thin/thin.c	2011/10/28 20:25:08	1.26
@@ -155,7 +155,8 @@
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 // FIXME  maybe switch to use  chunksize (as with snapshot ??)
-	outf(f, "data_block_size = %u", seg->data_block_size);
+	outsize(f, (uint64_t) seg->data_block_size,
+		"data_block_size = %u", seg->data_block_size);
 
 	if (seg->low_water_mark)
 		outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);


