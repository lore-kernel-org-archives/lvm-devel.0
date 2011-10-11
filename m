From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:06:10 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20111011090610.32568.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:06:10

Modified files:
	lib/config     : config.c 

Log message:
	Add missing log_error for alloc failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/lib/config/config.c	2011/09/02 01:59:07	1.106
+++ LVM2/lib/config/config.c	2011/10/11 09:06:09	1.107
@@ -99,8 +99,10 @@
 		}
 		fb = fb + mmap_offset;
 	} else {
-		if (!(buf = dm_malloc(size + size2)))
-			return_0;
+		if (!(buf = dm_malloc(size + size2))) {
+			log_error("Failed to allocate circular buffer.");
+			return 0;
+		}
 		if (!dev_read_circular(dev, (uint64_t) offset, size,
 				       (uint64_t) offset2, size2, buf)) {
 			goto out;


