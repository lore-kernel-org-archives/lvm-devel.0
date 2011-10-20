From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:35:55 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111020103555.7364.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:35:55

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Add last param 0 for thin-pool
	
	So now the table suppression works for thin-pool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/libdm/libdm-deptree.c	2011/10/20 10:33:30	1.136
+++ LVM2/libdm/libdm-deptree.c	2011/10/20 10:35:55	1.137
@@ -2086,7 +2086,7 @@
 			return_0;
 		EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %s", metadata, pool,
 			    seg->data_block_size, seg->low_water_mark,
-			    seg->skip_block_zeroing ? "1 skip_block_zeroing" : "");
+			    seg->skip_block_zeroing ? "1 skip_block_zeroing" : "0");
 		break;
 	case SEG_THIN:
 		if (!_build_dev_string(pool, sizeof(pool), seg->pool))


