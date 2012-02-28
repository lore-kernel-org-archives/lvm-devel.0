From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 10:10:07 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20120228101007.16089.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 10:10:07

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Explicitely ignore errors in label_read iteration.
	
	We don't want stack traces here, so mark as void.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/lib/cache/lvmcache.c	2012/02/23 22:23:13	1.128
+++ LVM2/lib/cache/lvmcache.c	2012/02/28 10:10:07	1.129
@@ -641,7 +641,7 @@
 	struct label *label;
 
 	if (info->status & CACHE_INVALID)
-		label_read(info->dev, &label, UINT64_C(0));
+		(void) label_read(info->dev, &label, UINT64_C(0));
 }
 
 static int _scan_invalid(void)
@@ -688,7 +688,7 @@
 	}
 
 	while ((dev = dev_iter_get(iter)))
-		label_read(dev, &label, UINT64_C(0));
+		(void) label_read(dev, &label, UINT64_C(0));
 
 	dev_iter_destroy(iter);
 


