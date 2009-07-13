From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: Mon, 13 Jul 2009 21:24:08 -0000
Subject: LVM2/lib/label label.c
Message-ID: <20090713212349.16145.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2009-07-13 21:23:48

Modified files:
	lib/label      : label.c 

Log message:
	Suppress warning on 64-bit big-endian computers (Sparc 64).
	
	xlate64 produces unsigned long long type, but PRIu64 is defined
	to accept argument unsigned long type (on 64-bit machines).
	
	On existing machines, both types have the same size, so it works,
	but it is still wrong and produces a warning.
	
	Fix it by using a cast to uint64_t --- according to the standard,
	PRIu64 argument matches type uint64_t.
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/lib/label/label.c	2009/07/08 22:18:32	1.47
+++ LVM2/lib/label/label.c	2009/07/13 21:23:48	1.48
@@ -138,7 +138,7 @@
 				log_info("%s: Label for sector %" PRIu64
 					 " found at sector %" PRIu64
 					 " - ignoring", dev_name(dev),
-					 xlate64(lh->sector_xl),
+					 (uint64_t)xlate64(lh->sector_xl),
 					 sector + scan_sector);
 				continue;
 			}


